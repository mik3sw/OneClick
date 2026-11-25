//
//  CustomItem.swift
//  OneClick
//

import Foundation

/// A user-defined toggle, button or info tile that runs shell commands.
struct CustomItem: Codable, Identifiable, Hashable {
    enum Kind: String, Codable, CaseIterable {
        case toggle
        case action
        /// Shows the output of a command and refreshes it periodically.
        case info

        var title: String {
            switch self {
            case .toggle: "Toggle"
            case .action: "Button"
            case .info: "Info"
            }
        }
    }

    var id = UUID()
    var name = ""
    var symbol = "terminal"
    var kind = Kind.toggle
    /// Runs when the toggle turns on, when the button is clicked, or to produce the info text.
    var onCommand = ""
    /// Runs when the toggle turns off.
    var offCommand = ""
    /// Optional. When set, the toggle is on if this command exits with status 0.
    var statusCommand = ""
    /// Optional heading the item is grouped under in the panel.
    var group = ""
    /// Runs the commands as root, after a Touch ID or password prompt.
    var runAsAdmin = false
    /// Asks for a second click in the panel before running.
    var requiresConfirmation = false
    /// Copies the button's output to the clipboard when it succeeds.
    var copiesOutput = false
    /// Seconds before a command is stopped. 0 means no limit.
    var timeout = 0
    /// Seconds between refreshes of an info tile while the panel is open.
    var refreshInterval = 60
    /// Global keyboard shortcut. Not included when sharing an item.
    var shortcut: HotKey?

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !onCommand.trimmingCharacters(in: .whitespaces).isEmpty
            && (kind != .toggle || !offCommand.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    /// The heading shown above the item in the panel.
    var displayGroup: String {
        let trimmed = group.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Custom" : trimmed
    }

    /// Added on first launch to show what custom items can do.
    static let examples = [
        CustomItem(
            name: "Mute",
            symbol: "speaker.slash",
            kind: .toggle,
            onCommand: "osascript -e 'set volume output muted true'",
            offCommand: "osascript -e 'set volume output muted false'",
            statusCommand: "osascript -e 'output muted of (get volume settings)' | grep -q true"
        ),
        CustomItem(
            name: "Kill Port 3000",
            symbol: "xmark.octagon",
            kind: .action,
            onCommand: """
                pids=$(lsof -ti tcp:3000 -sTCP:LISTEN); \
                if [ -z "$pids" ]; then echo "Nothing is listening on port 3000." >&2; exit 1; fi; \
                kill $pids
                """
        ),
        CustomItem(
            name: "Copy UUID",
            symbol: "number",
            kind: .action,
            onCommand: "uuidgen | tr -d '\\n' | pbcopy"
        ),
    ]
}

// MARK: - Coding

extension CustomItem {
    private enum CodingKeys: String, CodingKey {
        case id, name, symbol, kind, onCommand, offCommand, statusCommand, group
        case runAsAdmin, requiresConfirmation, copiesOutput, timeout, refreshInterval, shortcut
    }

    /// Decodes items saved by older versions, which lack the newer keys.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = CustomItem()
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? defaults.name
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? defaults.symbol
        kind = try container.decodeIfPresent(Kind.self, forKey: .kind) ?? defaults.kind
        onCommand = try container.decodeIfPresent(String.self, forKey: .onCommand) ?? ""
        offCommand = try container.decodeIfPresent(String.self, forKey: .offCommand) ?? ""
        statusCommand = try container.decodeIfPresent(String.self, forKey: .statusCommand) ?? ""
        group = try container.decodeIfPresent(String.self, forKey: .group) ?? ""
        runAsAdmin = try container.decodeIfPresent(Bool.self, forKey: .runAsAdmin) ?? false
        requiresConfirmation = try container.decodeIfPresent(Bool.self, forKey: .requiresConfirmation) ?? false
        copiesOutput = try container.decodeIfPresent(Bool.self, forKey: .copiesOutput) ?? false
        timeout = max(0, try container.decodeIfPresent(Int.self, forKey: .timeout) ?? 0)
        refreshInterval = max(1, try container.decodeIfPresent(Int.self, forKey: .refreshInterval) ?? 60)
        shortcut = try container.decodeIfPresent(HotKey.self, forKey: .shortcut)
    }

    /// A copy safe to share: fresh identity and no machine-specific shortcut.
    var sharable: CustomItem {
        var copy = self
        copy.id = UUID()
        copy.shortcut = nil
        return copy
    }
}
