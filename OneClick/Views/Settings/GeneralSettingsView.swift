//
//  GeneralSettingsView.swift
//  OneClick
//

import ServiceManagement
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.openURL) private var openURL
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var loginItemError: String?

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, enabled in
                        updateLoginItem(enabled)
                    }
                if let loginItemError {
                    Text(loginItemError)
                        .font(.callout)
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Startup")
            }

            Section {
                LabeledContent {
                    Button("Open Shortcuts") {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.shortcuts") {
                            NSWorkspace.shared.openApplication(at: url, configuration: .init())
                        }
                    }
                } label: {
                    Label {
                        Text("Shortcuts and Spotlight")
                        Text("Every item is available as an action: Run OneClick Item, Set OneClick Toggle and Get OneClick Toggle State.")
                    } icon: {
                        Image(systemName: "square.2.layers.3d")
                    }
                }
            } header: {
                Text("Automation")
            }

            Section {
                PermissionRow(
                    title: "Automation",
                    detail: "Needed for Dock, menu bar, Dark Mode and Empty Trash.",
                    symbol: "gearshape.2"
                ) {
                    openURL(SettingsPane.automation)
                }
                PermissionRow(
                    title: "Screen & System Audio Recording",
                    detail: "Needed to capture windows in screenshots.",
                    symbol: "rectangle.dashed.badge.record"
                ) {
                    openURL(SettingsPane.screenRecording)
                }
            } header: {
                Text("Permissions")
            } footer: {
                Text("macOS asks for these the first time a feature needs them.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private func updateLoginItem(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginItemError = nil
        } catch {
            loginItemError = error.localizedDescription
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}

private struct PermissionRow: View {
    let title: String
    let detail: String
    let symbol: String
    let open: () -> Void

    var body: some View {
        LabeledContent {
            Button("Open…", action: open)
        } label: {
            Label {
                Text(title)
                Text(detail)
            } icon: {
                Image(systemName: symbol)
            }
        }
    }
}
