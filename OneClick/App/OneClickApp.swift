//
//  OneClickApp.swift
//  OneClick
//

import SwiftUI

@main
struct OneClickApp: App {
    @State private var preferences: Preferences
    @State private var system: SystemController

    init() {
        let preferences = Preferences()
        _preferences = State(initialValue: preferences)
        _system = State(initialValue: SystemController(preferences: preferences))
    }

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
