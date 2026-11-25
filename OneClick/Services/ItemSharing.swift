//
//  ItemSharing.swift
//  OneClick
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Exports custom items to files and links, and imports them after the user reviews them.
enum ItemSharing {
    /// The file format: a version number plus the items, without IDs' meaning or shortcuts.
    private struct SharedFile: Codable {
        var oneclick = 1
        var items: [CustomItem]
    }

    // MARK: Files

    static func encode(_ items: [CustomItem]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(SharedFile(items: items.map(\.sharable)))
    }

    /// Accepts the shared file format or a bare array of items.
    static func decode(_ data: Data) throws -> [CustomItem] {
        let decoder = JSONDecoder()
        if let file = try? decoder.decode(SharedFile.self, from: data) { return file.items }
        if let items = try? decoder.decode([CustomItem].self, from: data) { return items }
        return [try decoder.decode(CustomItem.self, from: data)]
    }

    /// Asks where to save `items` and writes them as JSON.
    static func export(_ items: [CustomItem]) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = items.count == 1 ? "\(items[0].name).json" : "OneClick Items.json"
        panel.title = "Export Custom Items"
        NSApp.activate()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try encode(items).write(to: url, options: .atomic)
        } catch {
            showError("Couldn't export the items.", detail: error.localizedDescription)
        }
    }

    /// Asks for a file, then lets the user review its items before adding them.
    static func importFromFile(into preferences: Preferences) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = "Import Custom Items"
        NSApp.activate()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let items = try decode(Data(contentsOf: url)).filter(\.isValid)
            guard !items.isEmpty else {
                showError("No items to import.", detail: "The file doesn't contain any valid OneClick items.")
                return
            }
            review(items, into: preferences)
        } catch {
            showError("Couldn't read the file.", detail: "It isn't a OneClick items file.")
        }
    }

    // MARK: Links

    static let scheme = "oneclick"

    /// A `oneclick://add?…` link that adds `item` when opened.
    static func link(for item: CustomItem) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "add"
        var query: [URLQueryItem] = [
            URLQueryItem(name: "name", value: item.name),
            URLQueryItem(name: "kind", value: item.kind.rawValue),
            URLQueryItem(name: "symbol", value: item.symbol),
            URLQueryItem(name: "on", value: item.onCommand),
        ]
        func add(_ name: String, _ value: String, when condition: Bool) {
            if condition { query.append(URLQueryItem(name: name, value: value)) }
        }
        add("off", item.offCommand, when: item.kind == .toggle && !item.offCommand.isEmpty)
        add("status", item.statusCommand, when: item.kind == .toggle && !item.statusCommand.isEmpty)
        add("group", item.group, when: !item.group.isEmpty)
        add("admin", "1", when: item.runAsAdmin)
        add("confirm", "1", when: item.requiresConfirmation)
        add("copy", "1", when: item.kind == .action && item.copiesOutput)
        add("timeout", String(item.timeout), when: item.timeout > 0)
        add("refresh", String(item.refreshInterval), when: item.kind == .info)
        components.queryItems = query
        // URLComponents leaves "+" alone, which some apps read as a space.
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }

    /// Parses a `oneclick://add?…` link.
    static func item(from url: URL) -> CustomItem? {
        guard url.scheme?.lowercased() == scheme, url.host()?.lowercased() == "add",
              let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        else { return nil }
        func value(_ name: String) -> String? { query.first { $0.name == name }?.value }
        func flag(_ name: String) -> Bool { ["1", "true", "yes"].contains(value(name)?.lowercased() ?? "") }

        var item = CustomItem()
        item.name = value("name") ?? ""
        item.kind = value("kind").flatMap(CustomItem.Kind.init(rawValue:)) ?? .action
        item.symbol = value("symbol").flatMap { NSImage(systemSymbolName: $0, accessibilityDescription: nil) != nil ? $0 : nil }
            ?? item.symbol
        item.onCommand = value("on") ?? ""
        item.offCommand = value("off") ?? ""
        item.statusCommand = value("status") ?? ""
        item.group = value("group") ?? ""
        item.runAsAdmin = flag("admin")
        item.requiresConfirmation = flag("confirm")
        item.copiesOutput = flag("copy")
        item.timeout = max(0, value("timeout").flatMap(Int.init) ?? 0)
        item.refreshInterval = max(1, value("refresh").flatMap(Int.init) ?? 60)
        return item.isValid ? item : nil
    }

    static func copyLink(for item: CustomItem) {
        guard let url = link(for: item) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
    }

    /// Handles a link opened from a browser, Terminal or another app.
    static func open(_ url: URL, into preferences: Preferences) {
        guard let item = item(from: url) else {
            showError("This OneClick link isn't valid.", detail: url.absoluteString)
            return
        }
        review([item], into: preferences)
    }

    // MARK: Review

    /// Shows every command before anything is added. Nothing runs until the user clicks the item.
    static func review(_ items: [CustomItem], into preferences: Preferences) {
        let alert = NSAlert()
        alert.messageText = items.count == 1
            ? "Add “\(items[0].name)” to OneClick?"
            : "Add \(items.count) items to OneClick?"
        alert.informativeText = "Check the commands below. They run with your permissions when you use the item, so only add items from sources you trust."
        alert.addButton(withTitle: items.count == 1 ? "Add Item" : "Add Items")
        alert.addButton(withTitle: "Cancel")

        let review = NSHostingView(rootView: ImportReviewList(items: items))
        review.frame = NSRect(x: 0, y: 0, width: 420, height: min(320, CGFloat(items.count) * 120 + 20))
        alert.accessoryView = review

        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            preferences.importItems(items)
        }
    }

    private static func showError(_ message: String, detail: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.informativeText = detail
        NSApp.activate()
        alert.runModal()
    }
}

/// The items and commands shown before importing.
private struct ImportReviewList: View {
    let items: [CustomItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Image(systemName: item.symbol)
                            Text(item.name).font(.headline)
                            Text(item.kind.title + (item.runAsAdmin ? " · as administrator" : ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        command(item.kind == .toggle ? "On" : "Run", item.onCommand)
                        if item.kind == .toggle {
                            command("Off", item.offCommand)
                            if !item.statusCommand.isEmpty { command("Status", item.statusCommand) }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
        }
        .background(.background.secondary, in: .rect(cornerRadius: 8))
    }

    private func command(_ title: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
            Text(text)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
