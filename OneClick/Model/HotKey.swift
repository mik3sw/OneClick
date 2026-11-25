//
//  HotKey.swift
//  OneClick
//

import AppKit
import Carbon.HIToolbox

/// A global keyboard shortcut: a virtual key code plus modifier keys.
nonisolated struct HotKey: Codable, Hashable, Sendable {
    /// Carbon virtual key code (`kVK_*`).
    var keyCode: UInt32
    /// `NSEvent.ModifierFlags` raw value, limited to ⌃ ⌥ ⇧ ⌘.
    var modifiers: UInt
    /// The key as typed when the shortcut was recorded, e.g. "D".
    var key: String

    static let relevantModifiers: NSEvent.ModifierFlags = [.control, .option, .shift, .command]

    var modifierFlags: NSEvent.ModifierFlags { NSEvent.ModifierFlags(rawValue: modifiers) }

    /// Modifiers in the form `RegisterEventHotKey` expects.
    var carbonModifiers: UInt32 {
        var result: UInt32 = 0
        if modifierFlags.contains(.command) { result |= UInt32(cmdKey) }
        if modifierFlags.contains(.option) { result |= UInt32(optionKey) }
        if modifierFlags.contains(.control) { result |= UInt32(controlKey) }
        if modifierFlags.contains(.shift) { result |= UInt32(shiftKey) }
        return result
    }

    /// e.g. "⌃⌥D"
    var displayString: String {
        var text = ""
        if modifierFlags.contains(.control) { text += "⌃" }
        if modifierFlags.contains(.option) { text += "⌥" }
        if modifierFlags.contains(.shift) { text += "⇧" }
        if modifierFlags.contains(.command) { text += "⌘" }
        return text + key
    }

    /// Builds a shortcut from a key press, or returns nil if it can't be a global shortcut.
    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection(Self.relevantModifiers)
        let code = UInt32(event.keyCode)
        let functionKey = Self.functionKeyNames[code]
        // Plain letters would make typing impossible; require ⌃, ⌥ or ⌘ unless it's an F-key.
        guard functionKey != nil || !flags.intersection([.control, .option, .command]).isEmpty else {
            return nil
        }
        let label = Self.specialKeyNames[code] ?? functionKey
            ?? event.charactersIgnoringModifiers?.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let label, !label.isEmpty else { return nil }
        self.init(keyCode: code, modifiers: flags.rawValue, key: label)
    }

    init(keyCode: UInt32, modifiers: UInt, key: String) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.key = key
    }

    private static let functionKeyNames: [UInt32: String] = [
        UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3", UInt32(kVK_F4): "F4",
        UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6", UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8",
        UInt32(kVK_F9): "F9", UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12",
        UInt32(kVK_F13): "F13", UInt32(kVK_F14): "F14", UInt32(kVK_F15): "F15", UInt32(kVK_F16): "F16",
        UInt32(kVK_F17): "F17", UInt32(kVK_F18): "F18", UInt32(kVK_F19): "F19", UInt32(kVK_F20): "F20",
    ]

    private static let specialKeyNames: [UInt32: String] = [
        UInt32(kVK_Space): "Space", UInt32(kVK_Return): "↩", UInt32(kVK_Tab): "⇥",
        UInt32(kVK_Delete): "⌫", UInt32(kVK_ForwardDelete): "⌦", UInt32(kVK_Escape): "⎋",
        UInt32(kVK_LeftArrow): "←", UInt32(kVK_RightArrow): "→",
        UInt32(kVK_UpArrow): "↑", UInt32(kVK_DownArrow): "↓",
        UInt32(kVK_Home): "↖", UInt32(kVK_End): "↘",
        UInt32(kVK_PageUp): "⇞", UInt32(kVK_PageDown): "⇟",
    ]
}

extension HotKey {
    /// Same key combination, ignoring the recorded label.
    func matches(_ other: HotKey) -> Bool {
        keyCode == other.keyCode && modifiers == other.modifiers
    }
}

/// Points at a built-in or custom item, for shortcuts, links and App Intents.
nonisolated enum ItemReference: Hashable, Sendable {
    case feature(Feature)
    case custom(UUID)

    /// A stable string form, e.g. `feature:darkMode` or `custom:<UUID>`.
    var identifier: String {
        switch self {
        case .feature(let feature): "feature:\(feature.rawValue)"
        case .custom(let id): "custom:\(id.uuidString)"
        }
    }

    init?(identifier: String) {
        let parts = identifier.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        switch parts[0] {
        case "feature":
            guard let feature = Feature(rawValue: parts[1]) else { return nil }
            self = .feature(feature)
        case "custom":
            guard let id = UUID(uuidString: parts[1]) else { return nil }
            self = .custom(id)
        default:
            return nil
        }
    }
}
