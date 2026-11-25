//
//  OneClickIntents.swift
//  OneClick
//
//  Exposes every item to Shortcuts, Spotlight and Siri.
//

import AppIntents

// MARK: - Entities

/// Any built-in or custom item.
nonisolated struct ItemEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "OneClick Item"
    static let defaultQuery = ItemQuery()

    let id: String
    let name: String
    let symbol: String
    let kindTitle: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(kindTitle)", image: .init(systemName: symbol))
    }
}

/// A built-in or custom toggle, which can be turned on or off.
nonisolated struct ToggleEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "OneClick Toggle"
    static let defaultQuery = ToggleQuery()

    let id: String
    let name: String
    let symbol: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: .init(systemName: symbol))
    }
}

/// A snapshot of an item, read on the main actor.
nonisolated private struct ItemInfo: Sendable {
    let reference: ItemReference
    let name: String
    let symbol: String
    let kindTitle: String
    let isToggle: Bool

    var item: ItemEntity { ItemEntity(id: reference.identifier, name: name, symbol: symbol, kindTitle: kindTitle) }
    var toggle: ToggleEntity { ToggleEntity(id: reference.identifier, name: name, symbol: symbol) }

    /// Every built-in item in menu order, then every custom item.
    @MainActor static func all() -> [ItemInfo] {
        let preferences = AppServices.preferences
        let features = (preferences.toggleOrder + preferences.actionOrder).map { feature in
            ItemInfo(
                reference: .feature(feature), name: feature.title, symbol: feature.symbol(isOn: true),
                kindTitle: feature.kind == .toggle ? "Toggle" : "Action", isToggle: feature.kind == .toggle)
        }
        let custom = preferences.customItems.map { item in
            ItemInfo(
                reference: .custom(item.id), name: item.name, symbol: item.symbol,
                kindTitle: item.kind.title, isToggle: item.kind == .toggle)
        }
        return features + custom
    }
}

nonisolated struct ItemQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [ItemEntity] {
        let all = await ItemInfo.all()
        return identifiers.compactMap { id in all.first { $0.reference.identifier == id }?.item }
    }

    func entities(matching string: String) async throws -> [ItemEntity] {
        await ItemInfo.all().filter { $0.name.localizedStandardContains(string) }.map(\.item)
    }

    func suggestedEntities() async throws -> [ItemEntity] {
        await ItemInfo.all().map(\.item)
    }
}

nonisolated struct ToggleQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [ToggleEntity] {
        let all = await ItemInfo.all().filter(\.isToggle)
        return identifiers.compactMap { id in all.first { $0.reference.identifier == id }?.toggle }
    }

    func entities(matching string: String) async throws -> [ToggleEntity] {
        await ItemInfo.all().filter { $0.isToggle && $0.name.localizedStandardContains(string) }.map(\.toggle)
    }

    func suggestedEntities() async throws -> [ToggleEntity] {
        await ItemInfo.all().filter(\.isToggle).map(\.toggle)
    }
}

// MARK: - Errors

nonisolated enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case itemNotFound
    case failed(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .itemNotFound: "That OneClick item no longer exists."
        case .failed(let message): "\(message)"
        }
    }
}

/// Resolves an entity ID to a live item, on the main actor.
@MainActor
private func resolve(_ identifier: String) throws -> ResolvedItem {
    guard let reference = ItemReference(identifier: identifier) else { throw IntentError.itemNotFound }
    switch reference {
    case .feature(let feature):
        return .feature(feature)
    case .custom(let id):
        guard let item = AppServices.preferences.customItems.first(where: { $0.id == id }) else {
            throw IntentError.itemNotFound
        }
        return .custom(item)
    }
}

private enum ResolvedItem {
    case feature(Feature)
    case custom(CustomItem)
}

/// Runs `work`, turning command failures into errors Shortcuts can show.
@MainActor
private func performing<T>(_ work: () async throws -> T) async throws -> T {
    do {
        return try await work()
    } catch let error as IntentError {
        throw error
    } catch {
        throw IntentError.failed(error.localizedDescription)
    }
}

// MARK: - Intents

/// Does what clicking the item in the panel does, and returns any output.
struct RunItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Run OneClick Item"
    static let description = IntentDescription(
        "Flips a toggle, runs a button or action, or reads an info item. Returns the command's output, if any.")

    @Parameter(title: "Item")
    var item: ItemEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Run \(\.$item)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let system = AppServices.system
        let output: String = try await performing {
            switch try resolve(item.id) {
            case .feature(let feature) where feature.kind == .toggle:
                try await system.setAndWait(feature, on: !system.isOn(feature))
                return system.isOn(feature) ? "On" : "Off"
            case .feature(let feature):
                if feature == .emptyTrash {
                    try await requestConfirmation(actionName: .run, dialog: "Permanently erase the items in the Trash?")
                }
                try await system.runAndWait(feature)
                return ""
            case .custom(let custom):
                switch custom.kind {
                case .toggle:
                    if custom.requiresConfirmation {
                        try await requestConfirmation(actionName: .run, dialog: "Run “\(custom.name)”?")
                    }
                    let on = await system.currentState(of: custom)
                    try await system.setCustom(custom, on: !on)
                    return !on ? "On" : "Off"
                case .action:
                    if custom.requiresConfirmation {
                        try await requestConfirmation(actionName: .run, dialog: "Run “\(custom.name)”?")
                    }
                    return try await system.runCustom(custom)
                case .info:
                    return try await system.refreshInfo(custom)
                }
            }
        }
        return .result(value: output)
    }
}

/// Turns a toggle on or off, whatever its current state.
struct SetToggleIntent: AppIntent {
    static let title: LocalizedStringResource = "Set OneClick Toggle"
    static let description = IntentDescription("Turns a OneClick toggle on or off.")

    @Parameter(title: "Toggle")
    var toggle: ToggleEntity

    @Parameter(title: "On", default: true)
    var isOn: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Turn \(\.$toggle) \(\.$isOn)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let system = AppServices.system
        try await performing {
            switch try resolve(toggle.id) {
            case .feature(let feature):
                guard system.isOn(feature) != isOn else { return }
                try await system.setAndWait(feature, on: isOn)
            case .custom(let item):
                guard await system.currentState(of: item) != isOn else { return }
                try await system.setCustom(item, on: isOn)
            }
        }
        return .result()
    }
}

/// Reads whether a toggle is on, for use in conditions.
struct GetToggleStateIntent: AppIntent {
    static let title: LocalizedStringResource = "Get OneClick Toggle State"
    static let description = IntentDescription("Returns whether a OneClick toggle is currently on.")

    @Parameter(title: "Toggle")
    var toggle: ToggleEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Is \(\.$toggle) on")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let system = AppServices.system
        let isOn: Bool = try await performing {
            switch try resolve(toggle.id) {
            case .feature(let feature):
                system.refresh()
                return system.isOn(feature)
            case .custom(let item):
                return await system.currentState(of: item)
            }
        }
        return .result(value: isOn)
    }
}

// MARK: - App Shortcuts

/// Phrases for Spotlight and Siri, available without setting anything up.
struct OneClickShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RunItemIntent(),
            phrases: [
                "Run \(\.$item) with \(.applicationName)",
                "\(.applicationName) \(\.$item)",
            ],
            shortTitle: "Run Item",
            systemImageName: "bolt.fill"
        )
        AppShortcut(
            intent: SetToggleIntent(),
            phrases: [
                "Turn \(\.$toggle) on with \(.applicationName)",
                "Set \(\.$toggle) with \(.applicationName)",
            ],
            shortTitle: "Set Toggle",
            systemImageName: "switch.2"
        )
    }
}
