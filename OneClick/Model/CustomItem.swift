//
//  CustomItem.swift
//  OneClick
//

import Foundation

/// A user-defined toggle or button that runs shell commands.
struct CustomItem: Codable, Identifiable, Hashable {
    enum Kind: String, Codable, CaseIterable {
        case toggle
        case action
    }

    var id = UUID()
    var name = ""
    var symbol = "terminal"
    var kind = Kind.toggle
    /// Runs when the toggle turns on, or when the button is clicked.
    var onCommand = ""
    /// Runs when the toggle turns off.
    var offCommand = ""
    /// Optional. When set, the toggle is on if this command exits with status 0.
    var statusCommand = ""

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !onCommand.trimmingCharacters(in: .whitespaces).isEmpty
            && (kind == .action || !offCommand.trimmingCharacters(in: .whitespaces).isEmpty)
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
