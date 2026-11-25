//
//  Feature.swift
//  OneClick
//

import Foundation

/// A built-in OneClick function.
nonisolated enum Feature: String, CaseIterable, Identifiable, Codable, Sendable {
    // Toggles
    case hideDesktopIcons
    case showHiddenFiles
    case autohideDock
    case autohideMenuBar
    case darkMode
    case lowPowerMode
    case keepAwake
    case privacyMode
    // One-shot actions
    case emptyTrash
    case purgeMemory
    case screenshot

    enum Kind {
        case toggle
        case action
    }

    var id: Self { self }

    var kind: Kind {
        switch self {
        case .emptyTrash, .purgeMemory, .screenshot: .action
        default: .toggle
        }
    }

    var title: String {
        switch self {
        case .hideDesktopIcons: "Hide Desktop"
        case .showHiddenFiles: "Hidden Files"
        case .autohideDock: "Hide Dock"
        case .autohideMenuBar: "Hide Menu Bar"
        case .darkMode: "Dark Mode"
        case .lowPowerMode: "Low Power"
        case .keepAwake: "Keep Awake"
        case .privacyMode: "Privacy Mode"
        case .emptyTrash: "Empty Trash"
        case .purgeMemory: "Free Memory"
        case .screenshot: "Screenshot"
        }
    }

    /// Longer explanation, shown in Settings and as a tooltip.
    var summary: String {
        switch self {
        case .hideDesktopIcons: "Hide files and folders on the desktop."
        case .showHiddenFiles: "Show hidden files and folders in Finder."
        case .autohideDock: "Automatically hide and show the Dock."
        case .autohideMenuBar: "Automatically hide and show the menu bar."
        case .darkMode: "Switch between Light and Dark appearance."
        case .lowPowerMode: "Reduce energy use. Requires an administrator password."
        case .keepAwake: "Prevent the Mac and display from sleeping."
        case .privacyMode: "Hide desktop icons, Dock and menu bar at once."
        case .emptyTrash: "Permanently erase the items in the Trash."
        case .purgeMemory: "Flush disk caches from memory. Requires an administrator password."
        case .screenshot: "Capture the screen after 3 seconds into your screenshots folder."
        }
    }

    func symbol(isOn: Bool) -> String {
        switch self {
        case .hideDesktopIcons: "menubar.dock.rectangle"
        case .showHiddenFiles: isOn ? "eye" : "eye.slash"
        case .autohideDock: "dock.rectangle"
        case .autohideMenuBar: "menubar.rectangle"
        case .darkMode: isOn ? "moon.fill" : "sun.max.fill"
        case .lowPowerMode: isOn ? "battery.25percent" : "battery.100percent"
        case .keepAwake: isOn ? "cup.and.heat.waves.fill" : "cup.and.saucer"
        case .privacyMode: isOn ? "hand.raised.fill" : "hand.raised"
        case .emptyTrash: "trash"
        case .purgeMemory: "memorychip"
        case .screenshot: "camera.viewfinder"
        }
    }

    static var toggles: [Feature] { allCases.filter { $0.kind == .toggle } }
    static var actions: [Feature] { allCases.filter { $0.kind == .action } }
}
