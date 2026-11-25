//
//  CustomItemsSettingsView.swift
//  OneClick
//

import SwiftUI

/// Lists the user's custom toggles, buttons and info tiles.
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
                    Text("Add toggles, buttons and info tiles that run your own shell commands.")
                } actions: {
                    Button("Add Item") { editing = CustomItem() }
                        .buttonStyle(.glassProminent)
                    Button("Import…") { ItemSharing.importFromFile(into: preferences) }
                        .buttonStyle(.glass)
                }
            } else {
                List(selection: $selection) {
                    ForEach(preferences.customItems) { item in
                        CustomItemRow(item: item)
                            .tag(item.id)
                            .contextMenu { itemMenu(item) }
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
            CustomItemEditor(item: item, existingGroups: groups) { saved in
                preferences.upsert(saved)
            }
        }
    }

    @ViewBuilder
    private func itemMenu(_ item: CustomItem) -> some View {
        Button("Edit…") { editing = item }
        Button("Duplicate") { duplicate(item) }
        Divider()
        Button("Copy Link") { ItemSharing.copyLink(for: item) }
        Button("Export…") { ItemSharing.export([item]) }
        Divider()
        Button("Delete", role: .destructive) { preferences.remove(item) }
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
            Menu("More", systemImage: "ellipsis.circle") {
                Button("Import…") { ItemSharing.importFromFile(into: preferences) }
                Button("Export All…") { ItemSharing.export(preferences.customItems) }
                Divider()
                if let item = selectedItem {
                    Button("Export “\(item.name)”…") { ItemSharing.export([item]) }
                    Button("Copy Link to “\(item.name)”") { ItemSharing.copyLink(for: item) }
                    Button("Duplicate “\(item.name)”") { duplicate(item) }
                }
            }
            .menuIndicator(.hidden)
            .fixedSize()
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

    /// Group names already in use, for the editor's picker.
    private var groups: [String] {
        var seen = Set<String>()
        return preferences.customItems
            .map { $0.group.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    private func edit(_ id: CustomItem.ID?) {
        editing = preferences.customItems.first { $0.id == id }
    }

    private func duplicate(_ item: CustomItem) {
        var copy = item.sharable
        copy.name += " Copy"
        preferences.upsert(copy)
        selection = copy.id
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
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.group.isEmpty ? item.kind.title : "\(item.kind.title) · \(item.group)")
                if let shortcut = item.shortcut {
                    Text(shortcut.displayString)
                        .monospaced()
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if item.runAsAdmin {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .help("Runs as administrator")
            }
        }
        .padding(.vertical, 4)
    }
}
