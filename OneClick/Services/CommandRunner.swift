//
//  CommandRunner.swift
//  OneClick
//

import Foundation
import os

/// The outcome of a finished process.
nonisolated struct CommandResult: Sendable {
    let status: Int32
    let output: String
    let errorOutput: String

    var succeeded: Bool { status == 0 }
}

/// An error surfaced to the user when a command fails.
nonisolated struct CommandError: LocalizedError, Sendable {
    enum Kind: Sendable {
        /// The user dismissed an authorization prompt.
        case cancelled
        /// macOS denied the Apple Event (Privacy & Security › Automation).
        case automationDenied
        case failed
    }

    let kind: Kind
    let message: String

    var errorDescription: String? { message }
}

/// Runs external programs off the main thread.
nonisolated enum CommandRunner {

    /// Launches `executable` and waits for it to exit, collecting its output.
    /// With a `timeout` in seconds, the process and its children are stopped when it runs too long.
    @discardableResult
    static func run(_ executable: String, _ arguments: [String] = [], timeout: Int = 0) async throws -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        // Read both pipes while the process runs, so a large output can't fill
        // the pipe buffer and block the process forever.
        let outputReader = Task.detached { stdout.fileHandleForReading.readDataToEndOfFile() }
        let errorReader = Task.detached { stderr.fileHandleForReading.readDataToEndOfFile() }

        let timedOut = OSAllocatedUnfairLock(initialState: false)
        let status: Int32 = try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { continuation.resume(returning: $0.terminationStatus) }
            do {
                try process.run()
            } catch {
                process.terminationHandler = nil
                try? stdout.fileHandleForWriting.close()
                try? stderr.fileHandleForWriting.close()
                continuation.resume(throwing: error)
                return
            }
            guard timeout > 0 else { return }
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeout)) {
                guard process.isRunning else { return }
                timedOut.withLock { $0 = true }
                terminateTree(of: process.processIdentifier)
                process.terminate()
            }
        }
        // Our copies of the write ends must be closed, or the readers never see EOF.
        try? stdout.fileHandleForWriting.close()
        try? stderr.fileHandleForWriting.close()

        if timedOut.withLock({ $0 }) {
            outputReader.cancel()
            errorReader.cancel()
            throw CommandError(kind: .failed, message: "Stopped after \(timeout) seconds.")
        }
        let output = String(decoding: await outputReader.value, as: UTF8.self)
        let errorOutput = String(decoding: await errorReader.value, as: UTF8.self)
        return CommandResult(
            status: status,
            output: output.trimmingCharacters(in: .whitespacesAndNewlines),
            errorOutput: errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    /// Sends SIGTERM to the children of `pid`, so a timed-out shell doesn't leave them running.
    private static func terminateTree(of pid: Int32) {
        let pkill = Process()
        pkill.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        pkill.arguments = ["-TERM", "-P", String(pid)]
        try? pkill.run()
        pkill.waitUntilExit()
    }

    /// Runs a user-provided command line in a login shell, so PATH matches Terminal.
    /// With `asAdmin`, it runs as root after a Touch ID or password prompt.
    @discardableResult
    static func shell(_ command: String, asAdmin: Bool = false, timeout: Int = 0) async throws -> CommandResult {
        if asAdmin {
            // `do shell script` uses /bin/sh with a minimal PATH, so pass the user's PATH along.
            let path = try await loginPath()
            let line = "PATH=\(quoted(path)) /bin/zsh -c \(quoted(command))"
            let output = try await privileged(line, timeout: timeout)
            return CommandResult(status: 0, output: output, errorOutput: "")
        }
        let result = try await run("/bin/zsh", ["-l", "-c", command], timeout: timeout)
        guard result.succeeded else {
            let detail = result.errorOutput.isEmpty ? "exit code \(result.status)" : result.errorOutput
            throw CommandError(kind: .failed, message: "Command failed: \(detail)")
        }
        return result
    }

    /// The PATH of the user's login shell, cached after the first call.
    private static func loginPath() async throws -> String {
        if let cached = cachedPath.withLock({ $0 }) { return cached }
        let result = try await run("/bin/zsh", ["-l", "-c", "printf %s \"$PATH\""])
        let path = result.output.isEmpty ? "/usr/bin:/bin:/usr/sbin:/sbin" : result.output
        cachedPath.withLock { $0 = path }
        return path
    }

    private static let cachedPath = OSAllocatedUnfairLock<String?>(initialState: nil)

    /// Wraps `text` in single quotes for the shell.
    static func quoted(_ text: String) -> String {
        "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    /// Runs an AppleScript through `osascript` and maps common failures.
    @discardableResult
    static func appleScript(_ source: String, timeout: Int = 0) async throws -> String {
        let result = try await run("/usr/bin/osascript", ["-e", source], timeout: timeout)
        guard result.succeeded else { throw scriptError(from: result.errorOutput) }
        return result.output
    }

    /// Runs a shell command with administrator privileges (Touch ID or password prompt).
    @discardableResult
    static func privileged(_ command: String, timeout: Int = 0) async throws -> String {
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return try await appleScript(
            "do shell script \"\(escaped)\" with administrator privileges without altering line endings",
            timeout: timeout)
    }

    /// Writes a boolean preference for another app through `defaults`.
    static func writeDefault(domain: String, key: String, value: Bool) async throws {
        let result = try await run("/usr/bin/defaults", ["write", domain, key, "-bool", value ? "true" : "false"])
        guard result.succeeded else {
            throw CommandError(kind: .failed, message: "Couldn't update \(domain): \(result.errorOutput)")
        }
    }

    /// Restarts an app (e.g. Finder) so it picks up changed preferences.
    static func relaunch(_ processName: String) async throws {
        try await run("/usr/bin/killall", [processName])
    }

    private static func scriptError(from stderr: String) -> CommandError {
        if stderr.contains("-128") {
            return CommandError(kind: .cancelled, message: "Cancelled.")
        }
        if stderr.contains("-1743") || stderr.contains("Not authorized") {
            return CommandError(
                kind: .automationDenied,
                message: "OneClick isn't allowed to control this app. Allow it in Privacy & Security › Automation."
            )
        }
        let detail = stderr
            .components(separatedBy: "execution error: ").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? stderr
        return CommandError(kind: .failed, message: detail.isEmpty ? "The script failed." : detail)
    }
}
