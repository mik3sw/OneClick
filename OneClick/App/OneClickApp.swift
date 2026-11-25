//
//  OneClickApp.swift
//  OneClick
//

import AppIntents
import SwiftUI

/// The objects shared by the menu, Settings, keyboard shortcuts, links and App Intents.
enum AppServices {
    static let preferences = Preferences()
    static let system = SystemController(preferences: preferences)
}

@main
struct OneClickApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var preferences = AppServices.preferences
    @State private var system = AppServices.system

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environment(preferences)
                .environment(system)
        } label: {
            Image(.statusBarIcon)
                .accessibilityLabel("OneClick")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(preferences)
                .environment(system)
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let system = AppServices.system
        HotKeyCenter.shared.start(preferences: AppServices.preferences) { system.trigger($0) }
        observeItemsForShortcutsApp()
        // SwiftUI would otherwise take the link and just open the menu bar panel.
        NSAppleEventManager.shared().setEventHandler(
            self, andSelector: #selector(handleURLEvent(_:replyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    /// Opens `oneclick://add?…` links.
    @objc private func handleURLEvent(_ event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let string = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
              let url = URL(string: string)
        else { return }
        // Let the Apple Event finish before showing a modal alert.
        DispatchQueue.main.async {
            ItemSharing.open(url, into: AppServices.preferences)
        }
    }

    /// Lets the Shortcuts app and Spotlight offer phrases for the current custom items.
    private func observeItemsForShortcutsApp() {
        withObservationTracking {
            _ = AppServices.preferences.customItems
        } onChange: { [weak self] in
            Task { @MainActor in
                OneClickShortcuts.updateAppShortcutParameters()
                self?.observeItemsForShortcutsApp()
            }
        }
    }
}
