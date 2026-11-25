//
//  MenuSettingsView.swift
//  OneClick
//

import SwiftUI

/// Choose which built-in items appear in the menu, and drag to reorder them.
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
                Text("Drag items to change their order in the menu.")
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
        Toggle(isOn: Binding(
            get: { preferences.isVisible(feature) },
            set: { preferences.setVisible(feature, $0) }
        )) {
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
            }
        }
        .toggleStyle(.switch)
        .padding(.vertical, 2)
    }
}
