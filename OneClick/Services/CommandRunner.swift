//
//  CommandRunner.swift
//  OneClick
//

import Foundation

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
    @discardableResult
    static func run(_ executable: String, _ arguments: [String] = []) async throws -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        let status: Int32 = try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { continuation.resume(returning: $0.terminationStatus) }
            do {
                try process.run()
            } catch {
                process.terminationHandler = nil
                continuation.resume(throwing: error)
            }
        }

        // Both pipes are at EOF once the process has exited.
        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let errorOutput = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        return CommandResult(
            status: status,
            output: output.trimmingCharacters(in: .whitespacesAndNewlines),
            errorOutput: errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    /// Runs a user-provided command line in a login shell, so PATH matches Terminal.
    @discardableResult
    static func shell(_ command: String) async throws -> CommandResult {
        let result = try await run("/bin/zsh", ["-l", "-c", command])
        guard result.succeeded else {
            let detail = result.errorOutput.isEmpty ? "exit code \(result.status)" : result.errorOutput
            throw CommandError(kind: .failed, message: "Command failed: \(detail)")
        }
        return result
    }

    /// Runs an AppleScript through `osascript` and maps common failures.
    @discardableResult
    static func appleScript(_ source: String) async throws -> String {
        let result = try await run("/usr/bin/osascript", ["-e", source])
        guard result.succeeded else { throw scriptError(from: result.errorOutput) }
        return result.output
    }

    /// Runs a shell command with administrator privileges (Touch ID or password prompt).
    static func privileged(_ command: String) async throws {
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        try await appleScript("do shell script \"\(escaped)\" with administrator privileges")
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
