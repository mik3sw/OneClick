//
//  MenuSettingsView.swift
//  OneClick
//

import SwiftUI

/// Choose which built-in items appear in the menu, their shortcuts, and drag to reorder them.
struct MenuSettingsView: View {
    @Environment(Preferences.self) private var preferences

    var body: some View {
        List {
            Section {
                ForEach(preferences.toggleOrder) { feature in
                    FeatureVisibilityRow(feature: feature)
                }
                .onMove(perform: preferences.moveToggles)
            } header: {
                Text("Toggles")
            }

            Section {
                ForEach(preferences.actionOrder) { feature in
                    FeatureVisibilityRow(feature: feature)
                }
                .onMove(perform: preferences.moveActions)
            } header: {
                Text("Actions")
            } footer: {
                Text("Drag items to change their order in the menu. Shortcuts work everywhere, even when the item is hidden.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }
}

private struct FeatureVisibilityRow: View {
    @Environment(Preferences.self) private var preferences
    let feature: Feature

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: feature.symbol(isOn: true))
                .foregroundStyle(.tint)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                Text(feature.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            ShortcutRecorder(shortcut: Binding(
                get: { preferences.shortcut(for: feature) },
                set: { preferences.setShortcut($0, for: feature) }
            ))
            .controlSize(.small)
            Toggle("Show in menu", isOn: Binding(
                get: { preferences.isVisible(feature) },
                set: { preferences.setVisible(feature, $0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .help("Show in menu")
        }
        .padding(.vertical, 2)
    }
}
