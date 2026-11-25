//
//  SystemController.swift
//  OneClick
//

import AppKit
import Observation

/// The output of an info tile.
struct InfoValue: Equatable {
    let text: String
    let date: Date
    /// The text is an error message.
    let failed: Bool
}

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
    /// Items whose output was just copied, shown briefly as "Copied".
    private(set) var copiedCustomItems: Set<UUID> = []
    /// The latest output of each info tile.
    private(set) var infoValues: [UUID: InfoValue] = [:]
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
    func didJustCopy(_ item: CustomItem) -> Bool { copiedCustomItems.contains(item.id) }
    func infoValue(_ item: CustomItem) -> InfoValue? { infoValues[item.id] }

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

    /// Runs a custom item from the panel or a shortcut: flips a toggle, runs a button,
    /// or copies an info tile's text. Errors appear in the panel.
    func activate(_ item: CustomItem) {
        guard !isBusy(item) else { return }
        error = nil
        Task {
            do {
                switch item.kind {
                case .toggle: try await setCustom(item, on: !isOn(item))
                case .action: _ = try await runCustom(item)
                case .info: try await copyInfo(item)
                }
            } catch {
                report(error)
            }
        }
    }

    /// Turns a custom toggle on or off and waits for its command to finish.
    func setCustom(_ item: CustomItem, on turningOn: Bool) async throws {
        guard item.kind == .toggle, !isBusy(item) else { return }
        busyCustomItems.insert(item.id)
        customStates[item.id] = turningOn
        defer { busyCustomItems.remove(item.id) }
        do {
            try await CommandRunner.shell(
                turningOn ? item.onCommand : item.offCommand, asAdmin: item.runAsAdmin, timeout: item.timeout)
            if item.statusCommand.isEmpty {
                preferences.customToggleStates[item.id] = turningOn
            }
        } catch {
            await refreshCustomStates()
            throw error
        }
        await refreshCustomStates()
    }

    /// Runs a custom button and returns what it printed.
    @discardableResult
    func runCustom(_ item: CustomItem) async throws -> String {
        guard item.kind == .action, !isBusy(item) else { return "" }
        busyCustomItems.insert(item.id)
        defer { busyCustomItems.remove(item.id) }
        let result = try await CommandRunner.shell(item.onCommand, asAdmin: item.runAsAdmin, timeout: item.timeout)
        if item.copiesOutput, !result.output.isEmpty {
            copyToClipboard(result.output)
            flash(item.id, in: \.copiedCustomItems)
        } else {
            flash(item.id, in: \.completedCustomItems)
        }
        return result.output
    }

    /// Re-runs an info tile's command and returns the new text.
    @discardableResult
    func refreshInfo(_ item: CustomItem) async throws -> String {
        guard item.kind == .info else { return "" }
        if busyCustomItems.contains(item.id), let value = infoValues[item.id] { return value.text }
        busyCustomItems.insert(item.id)
        defer { busyCustomItems.remove(item.id) }
        do {
            let result = try await CommandRunner.shell(item.onCommand, asAdmin: item.runAsAdmin, timeout: item.timeout)
            let text = result.output.isEmpty ? "–" : result.output
            infoValues[item.id] = InfoValue(text: text, date: .now, failed: false)
            return text
        } catch {
            infoValues[item.id] = InfoValue(text: error.localizedDescription, date: .now, failed: true)
            throw error
        }
    }

    /// Copies an info tile's current text, refreshing it first if it has none yet.
    private func copyInfo(_ item: CustomItem) async throws {
        let text: String
        if let value = infoValues[item.id], !value.failed {
            text = value.text
        } else {
            text = try await refreshInfo(item)
        }
        copyToClipboard(text)
        flash(item.id, in: \.copiedCustomItems)
    }

    /// Keeps info tiles up to date while the panel is open. Cancel the calling task to stop.
    func monitorInfoItems() async {
        while !Task.isCancelled {
            for item in preferences.customItems where item.kind == .info && !isBusy(item) {
                let age = infoValues[item.id].map { Date.now.timeIntervalSince($0.date) } ?? .infinity
                if age >= Double(item.refreshInterval) {
                    Task { try? await refreshInfo(item) }
                }
            }
            try? await Task.sleep(for: .seconds(1))
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func flash(_ id: UUID, in set: ReferenceWritableKeyPath<SystemController, Set<UUID>>) {
        self[keyPath: set].insert(id)
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            self[keyPath: set].remove(id)
        }
    }

    // MARK: References

    /// Activates an item by reference, as a keyboard shortcut does.
    func trigger(_ reference: ItemReference) {
        switch reference {
        case .feature(let feature):
            feature.kind == .toggle ? toggle(feature) : run(feature)
        case .custom(let id):
            if let item = preferences.customItems.first(where: { $0.id == id }) {
                activate(item)
            }
        }
    }

    /// Turns a built-in toggle on or off and waits until it's done.
    func setAndWait(_ feature: Feature, on: Bool) async throws {
        guard feature.kind == .toggle else { return }
        busyFeatures.insert(feature)
        defer {
            busyFeatures.remove(feature)
            refresh()
        }
        states[feature] = on
        try await apply(feature, on: on)
    }

    /// Runs a built-in action and waits until it's done.
    func runAndWait(_ feature: Feature) async throws {
        guard feature.kind == .action else { return }
        busyFeatures.insert(feature)
        defer { busyFeatures.remove(feature) }
        try await runAction(feature)
    }

    /// Reads a custom toggle's real state, running its status check if it has one.
    func currentState(of item: CustomItem) async -> Bool {
        await refreshCustomStates()
        return isOn(item)
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
