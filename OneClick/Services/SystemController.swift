//
//  SystemController.swift
//  OneClick
//

import AppKit
import Observation

/// A problem to show in the menu, optionally with a shortcut to the relevant settings pane.
struct ErrorNotice: Equatable {
    let message: String
    var settingsURL: URL?
}

/// Reads the current state of every feature and applies changes.
@Observable
final class SystemController {
    private(set) var states: [Feature: Bool] = [:]
    private(set) var customStates: [UUID: Bool] = [:]
    private(set) var busyFeatures: Set<Feature> = []
    private(set) var busyCustomItems: Set<UUID> = []
    /// Custom buttons that just finished successfully, shown briefly as "Done".
    private(set) var completedCustomItems: Set<UUID> = []
    var error: ErrorNotice?

    private let preferences: Preferences
    private let keepAwake = KeepAwake()
    private var observers: [NSObjectProtocol] = []

    init(preferences: Preferences) {
        self.preferences = preferences
        refresh()
        observeSystemChanges()
    }

    // MARK: State

    func isOn(_ feature: Feature) -> Bool { states[feature] ?? false }
    func isBusy(_ feature: Feature) -> Bool { busyFeatures.contains(feature) }
    func isOn(_ item: CustomItem) -> Bool { customStates[item.id] ?? false }
    func isBusy(_ item: CustomItem) -> Bool { busyCustomItems.contains(item.id) }
    func didJustComplete(_ item: CustomItem) -> Bool { completedCustomItems.contains(item.id) }

    /// Re-reads every toggle from the system.
    func refresh() {
        let hideDesktop = !(SystemDefaults.bool("CreateDesktop", in: SystemDefaults.finder) ?? true)
        let dock = SystemDefaults.bool("autohide", in: SystemDefaults.dock) ?? false
        let menuBar = SystemDefaults.bool("_HIHideMenuBar", in: SystemDefaults.global) ?? false

        states = [
            .hideDesktopIcons: hideDesktop,
            .showHiddenFiles: SystemDefaults.bool("AppleShowAllFiles", in: SystemDefaults.finder) ?? false,
            .autohideDock: dock,
            .autohideMenuBar: menuBar,
            .darkMode: SystemDefaults.string("AppleInterfaceStyle", in: SystemDefaults.global) == "Dark",
            .lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
            .keepAwake: keepAwake.isActive,
            .privacyMode: hideDesktop && dock && menuBar,
        ]
        Task { await refreshCustomStates() }
    }

    private func refreshCustomStates() async {
        var result: [UUID: Bool] = [:]
        for item in preferences.customItems where item.kind == .toggle {
            if item.statusCommand.isEmpty {
                result[item.id] = preferences.customToggleStates[item.id] ?? false
            } else {
                let status = try? await CommandRunner.run("/bin/zsh", ["-l", "-c", item.statusCommand])
                result[item.id] = status?.succeeded ?? false
            }
        }
        customStates = result
    }

    // MARK: Built-in features

    func toggle(_ feature: Feature) {
        set(feature, on: !isOn(feature))
    }

    func set(_ feature: Feature, on: Bool) {
        guard feature.kind == .toggle, !isBusy(feature) else { return }
        perform(feature) { [self] in
            states[feature] = on
            try await apply(feature, on: on)
        }
    }

    /// Runs a one-shot action such as emptying the Trash.
    func run(_ feature: Feature) {
        guard feature.kind == .action, !isBusy(feature) else { return }
        perform(feature) { [self] in try await runAction(feature) }
    }

    private func perform(_ feature: Feature, _ work: @escaping () async throws -> Void) {
        busyFeatures.insert(feature)
        error = nil
        Task {
            defer {
                busyFeatures.remove(feature)
                refresh()
            }
            do {
                try await work()
            } catch {
                report(error)
            }
        }
    }

    private func apply(_ feature: Feature, on: Bool) async throws {
        switch feature {
        case .hideDesktopIcons:
            try await CommandRunner.writeDefault(domain: SystemDefaults.finder, key: "CreateDesktop", value: !on)
            try await CommandRunner.relaunch("Finder")
        case .showHiddenFiles:
            try await CommandRunner.writeDefault(domain: SystemDefaults.finder, key: "AppleShowAllFiles", value: on)
            try await CommandRunner.relaunch("Finder")
        case .autohideDock:
            try await CommandRunner.appleScript(
                "tell application \"System Events\" to set autohide of dock preferences to \(on)")
        case .autohideMenuBar:
            try await CommandRunner.appleScript(
                "tell application \"System Events\" to set autohide menu bar of dock preferences to \(on)")
        case .darkMode:
            try await CommandRunner.appleScript(
                "tell application \"System Events\" to tell appearance preferences to set dark mode to \(on)")
        case .lowPowerMode:
            try await CommandRunner.privileged("/usr/bin/pmset -a lowpowermode \(on ? 1 : 0)")
        case .keepAwake:
            try keepAwake.setActive(on)
        case .privacyMode:
            for part in [Feature.hideDesktopIcons, .autohideDock, .autohideMenuBar] where isOn(part) != on {
                try await apply(part, on: on)
            }
        case .emptyTrash, .purgeMemory, .screenshot:
            break
        }
    }

    private func runAction(_ feature: Feature) async throws {
        switch feature {
        case .emptyTrash:
            try await CommandRunner.appleScript("tell application \"Finder\" to empty trash")
        case .purgeMemory:
            try await CommandRunner.privileged("/usr/sbin/purge")
        case .screenshot:
            let result = try await CommandRunner.run(
                "/usr/sbin/screencapture", ["-T", "3", "-t", "png", Self.newScreenshotURL().path])
            guard result.succeeded else {
                throw CommandError(kind: .failed, message: "Screenshot failed: \(result.errorOutput)")
            }
        default:
            break
        }
    }

    /// A file in the folder chosen in the Screenshot app, falling back to the Desktop.
    private static func newScreenshotURL() -> URL {
        let folder = SystemDefaults.string("location", in: SystemDefaults.screenCapture)
            .map { URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath, isDirectory: true) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appending(path: "Desktop", directoryHint: .isDirectory)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return folder.appending(path: "Screenshot \(formatter.string(from: .now)).png")
    }

    // MARK: Custom items

    func activate(_ item: CustomItem) {
        guard !isBusy(item) else { return }
        let turningOn = item.kind == .action || !isOn(item)
        busyCustomItems.insert(item.id)
        error = nil
        if item.kind == .toggle { customStates[item.id] = turningOn }

        Task {
            defer { busyCustomItems.remove(item.id) }
            do {
                try await CommandRunner.shell(turningOn ? item.onCommand : item.offCommand)
                if item.kind == .toggle, item.statusCommand.isEmpty {
                    preferences.customToggleStates[item.id] = turningOn
                }
                if item.kind == .action {
                    flashCompletion(of: item.id)
                }
            } catch {
                report(error)
            }
            await refreshCustomStates()
        }
    }

    private func flashCompletion(of id: UUID) {
        completedCustomItems.insert(id)
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            completedCustomItems.remove(id)
        }
    }

    // MARK: Errors

    private func report(_ error: Error) {
        guard let commandError = error as? CommandError else {
            self.error = ErrorNotice(message: error.localizedDescription)
            return
        }
        switch commandError.kind {
        case .cancelled:
            break
        case .automationDenied:
            self.error = ErrorNotice(message: commandError.message, settingsURL: SettingsPane.automation)
        case .failed:
            self.error = ErrorNotice(message: commandError.message)
        }
    }

    // MARK: Observation

    private func observeSystemChanges() {
        let refreshOnMain: @Sendable (Notification) -> Void = { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        observers = [
            DistributedNotificationCenter.default().addObserver(
                forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: .main,
                using: refreshOnMain),
            NotificationCenter.default.addObserver(
                forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main, using: refreshOnMain),
        ]
    }
}

/// Deep links into System Settings.
enum SettingsPane {
    static let automation = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
    static let screenRecording = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
}
