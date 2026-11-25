//
//  Preferences.swift
//  OneClick
//

import Foundation
import Observation

/// User configuration: which built-in items appear, in what order, and custom items.
@Observable
final class Preferences {
    private(set) var toggleOrder: [Feature]
    private(set) var actionOrder: [Feature]
    var hiddenFeatures: Set<Feature> { didSet { save() } }
    var customItems: [CustomItem] { didSet { save() } }
    /// Last known state of custom toggles that have no status command.
    var customToggleStates: [UUID: Bool] { didSet { save() } }

    private let defaults: UserDefaults

    private enum Key {
        static let toggleOrder = "toggleOrder"
        static let actionOrder = "actionOrder"
        static let hiddenFeatures = "hiddenFeatures"
        static let customItems = "customItems"
        static let customToggleStates = "customToggleStates"
        static let didAddExamples = "didAddExampleCustomItems"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        toggleOrder = Self.completeOrder(Self.load([Feature].self, Key.toggleOrder, from: defaults), with: Feature.toggles)
        actionOrder = Self.completeOrder(Self.load([Feature].self, Key.actionOrder, from: defaults), with: Feature.actions)
        hiddenFeatures = Self.load(Set<Feature>.self, Key.hiddenFeatures, from: defaults) ?? []
        customItems = Self.load([CustomItem].self, Key.customItems, from: defaults) ?? []
        customToggleStates = Self.load([UUID: Bool].self, Key.customToggleStates, from: defaults) ?? [:]
        migrateLegacySettings()
        addExamplesOnce()
    }

    // MARK: Visible items

    var visibleToggles: [Feature] { toggleOrder.filter { !hiddenFeatures.contains($0) } }
    var visibleActions: [Feature] { actionOrder.filter { !hiddenFeatures.contains($0) } }

    func isVisible(_ feature: Feature) -> Bool { !hiddenFeatures.contains(feature) }

    func setVisible(_ feature: Feature, _ visible: Bool) {
        if visible { hiddenFeatures.remove(feature) } else { hiddenFeatures.insert(feature) }
    }

    func moveToggles(from source: IndexSet, to destination: Int) {
        toggleOrder.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func moveActions(from source: IndexSet, to destination: Int) {
        actionOrder.move(fromOffsets: source, toOffset: destination)
        save()
    }

    // MARK: Custom items

    func upsert(_ item: CustomItem) {
        if let index = customItems.firstIndex(where: { $0.id == item.id }) {
            customItems[index] = item
        } else {
            customItems.append(item)
        }
    }

    func remove(_ item: CustomItem) {
        customItems.removeAll { $0.id == item.id }
        customToggleStates[item.id] = nil
    }

    func moveCustomItems(from source: IndexSet, to destination: Int) {
        customItems.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: Persistence

    private func save() {
        Self.store(toggleOrder, Key.toggleOrder, in: defaults)
        Self.store(actionOrder, Key.actionOrder, in: defaults)
        Self.store(hiddenFeatures, Key.hiddenFeatures, in: defaults)
        Self.store(customItems, Key.customItems, in: defaults)
        Self.store(customToggleStates, Key.customToggleStates, in: defaults)
    }

    private static func load<T: Decodable>(_ type: T.Type, _ key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func store<T: Encodable>(_ value: T, _ key: String, in defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    /// Keeps a saved order, dropping unknown entries and appending features added later.
    private static func completeOrder(_ saved: [Feature]?, with all: [Feature]) -> [Feature] {
        let kept = (saved ?? []).filter(all.contains)
        return kept + all.filter { !kept.contains($0) }
    }

    /// Adds the example custom items the first time 3.x runs. Deleted examples stay deleted.
    private func addExamplesOnce() {
        guard !defaults.bool(forKey: Key.didAddExamples) else { return }
        defaults.set(true, forKey: Key.didAddExamples)
        let existingNames = Set(customItems.map(\.name))
        customItems += CustomItem.examples.filter { !existingNames.contains($0.name) }
    }

    /// Imports settings saved by OneClick 2.x, then removes the old keys.
    private func migrateLegacySettings() {
        let legacyVisibility: [String: Feature] = [
            "OneT": .hideDesktopIcons, "TwoT": .showHiddenFiles, "ThreeT": .autohideDock,
            "FourT": .autohideMenuBar, "FiveT": .lowPowerMode, "SixT": .darkMode,
            "SevenT": .keepAwake, "EightT": .privacyMode, "NineT": .emptyTrash,
            "TenT": .purgeMemory, "ElevenT": .screenshot,
        ]
        var hidden = hiddenFeatures
        for (key, feature) in legacyVisibility where defaults.object(forKey: key) != nil {
            // In 2.x a `true` value meant the item was hidden.
            if defaults.bool(forKey: key) { hidden.insert(feature) }
            defaults.removeObject(forKey: key)
        }
        if hidden != hiddenFeatures { hiddenFeatures = hidden }

        if defaults.bool(forKey: "CustomT"),
           let name = defaults.string(forKey: "CustomName"), !name.isEmpty {
            upsert(CustomItem(
                name: name,
                symbol: defaults.string(forKey: "CustomIcon").flatMap { $0.isEmpty ? nil : $0 } ?? "command",
                kind: .toggle,
                onCommand: defaults.string(forKey: "CustomCommandTrue") ?? "",
                offCommand: defaults.string(forKey: "CustomCommandFalse") ?? ""
            ))
        }
        for key in ["CustomT", "CustomName", "CustomIcon", "CustomCommandTrue", "CustomCommandFalse",
                    "light", "dark", "showPreview", "fontSize"] {
            defaults.removeObject(forKey: key)
        }
    }
}
