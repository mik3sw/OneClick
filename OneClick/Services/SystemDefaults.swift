//
//  SystemDefaults.swift
//  OneClick
//

import Foundation

/// Reads preferences that belong to other apps (Finder, Dock, the global domain)
/// directly through CFPreferences, without spawning `defaults`.
nonisolated enum SystemDefaults {
    static let finder = "com.apple.finder"
    static let dock = "com.apple.dock"
    static let screenCapture = "com.apple.screencapture"
    static let global = kCFPreferencesAnyApplication as String

    static func value(_ key: String, in domain: String) -> Any? {
        CFPreferencesAppSynchronize(domain as CFString)
        return CFPreferencesCopyAppValue(key as CFString, domain as CFString)
    }

    static func bool(_ key: String, in domain: String) -> Bool? {
        switch value(key, in: domain) {
        case let number as NSNumber:
            return number.boolValue
        case let string as String:
            return ["1", "true", "yes"].contains(string.lowercased())
        default:
            return nil
        }
    }

    static func string(_ key: String, in domain: String) -> String? {
        value(key, in: domain) as? String
    }
}
