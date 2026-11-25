//
//  CustomItemsSettingsView.swift
//  OneClick
//

import SwiftUI

/// Lists the user's custom toggles and buttons.
struct CustomItemsSettingsView: View {
    @Environment(Preferences.self) private var preferences
    @State private var editing: CustomItem?
    @State private var selection: CustomItem.ID?

    var body: some View {
        VStack(spacing: 0) {
            if preferences.customItems.isEmpty {
                ContentUnavailableView {
                    Label("No Custom Items", systemImage: "terminal")
                } description: {
                    Text("Add toggles and buttons that run your own shell commands.")
                } actions: {
                    Button("Add Item") { editing = CustomItem() }
                        .buttonStyle(.glassProminent)
                }
            } else {
                List(selection: $selection) {
                    ForEach(preferences.customItems) { item in
                        CustomItemRow(item: item)
                            .tag(item.id)
                            .contextMenu {
                                Button("Edit…") { editing = item }
                                Button("Delete", role: .destructive) { preferences.remove(item) }
                            }
                    }
                    .onMove(perform: preferences.moveCustomItems)
                }
                .listStyle(.inset)
                .contextMenu(forSelectionType: CustomItem.ID.self) { _ in
                } primaryAction: { ids in
                    edit(ids.first)
                }

                Divider()
                toolbar
            }
        }
        .sheet(item: $editing) { item in
            CustomItemEditor(item: item) { saved in
                preferences.upsert(saved)
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 4) {
            Button("Add", systemImage: "plus") { editing = CustomItem() }
            Button("Remove", systemImage: "minus") {
                if let item = selectedItem {
                    preferences.remove(item)
                    selection = nil
                }
            }
            .disabled(selectedItem == nil)
            Spacer()
            Button("Edit…") { edit(selection) }
                .disabled(selectedItem == nil)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(8)
    }

    private var selectedItem: CustomItem? {
        preferences.customItems.first { $0.id == selection }
    }

    private func edit(_ id: CustomItem.ID?) {
        editing = preferences.customItems.first { $0.id == id }
    }
}

private struct CustomItemRow: View {
    let item: CustomItem

    var body: some View {
        HStack(spacing: 10) {
            TileGlyph(symbol: item.symbol, isOn: true)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                Text(item.onCommand)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Text(item.kind == .toggle ? "Toggle" : "Button")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
