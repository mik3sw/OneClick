//
//  SymbolCatalog.swift
//  OneClick
//

import Foundation

/// Every SF Symbol installed with macOS, with the categories and search keywords
/// the SF Symbols app uses. Read from the system's CoreGlyphs bundle; there is no
/// public API for this, so a small built-in list is used if the files are missing.
nonisolated struct SymbolCatalog: Sendable {
    struct Category: Identifiable, Hashable, Sendable {
        let key: String
        let symbol: String
        var id: String { key }

        static func == (lhs: Category, rhs: Category) -> Bool { lhs.key == rhs.key }
        func hash(into hasher: inout Hasher) { hasher.combine(key) }

        var title: String {
            Self.titles[key] ?? key.capitalized
        }

        static let all = Category(key: "all", symbol: "square.grid.2x2")

        private static let titles = [
            "all": "All", "whatsnew": "What's New", "draw": "Draw",
            "communication": "Communication", "weather": "Weather", "maps": "Maps",
            "objectsandtools": "Objects & Tools", "devices": "Devices",
            "cameraandphotos": "Camera & Photos", "gaming": "Gaming",
            "connectivity": "Connectivity", "transportation": "Transportation",
            "automotive": "Automotive", "accessibility": "Accessibility",
            "privacyandsecurity": "Privacy & Security", "human": "Human", "home": "Home",
            "fitness": "Fitness", "nature": "Nature", "editing": "Editing",
            "textformatting": "Text Formatting", "media": "Media", "keyboard": "Keyboard",
            "commerce": "Commerce", "time": "Time", "health": "Health", "shapes": "Shapes",
            "arrows": "Arrows", "indices": "Indices", "math": "Math",
        ]
    }

    let symbols: [String]
    let categories: [Category]
    private let categoriesBySymbol: [String: [String]]
    private let keywordsBySymbol: [String: [String]]

    /// Symbols in a category whose name or keywords contain every word of `query`,
    /// best matches first.
    func symbols(in category: Category, matching query: String) -> [String] {
        let inCategory = category == .all
            ? symbols
            : symbols.filter { categoriesBySymbol[$0]?.contains(category.key) == true }
        let words = query.lowercased().split(separator: " ").map(String.init)
        guard !words.isEmpty else { return inCategory }

        let normalized = words.joined(separator: ".")
        var scored: [(name: String, score: Int)] = []
        for name in inCategory {
            let components = name.split(separator: ".")
            let keywords = keywordsBySymbol[name] ?? []
            var worst = 0
            var matchesAll = true
            for word in words {
                let score: Int
                if components.contains(where: { $0.hasPrefix(word) }) {
                    score = 1
                } else if keywords.contains(where: { $0.hasPrefix(word) }) {
                    score = 2
                } else if name.contains(word) || keywords.contains(where: { $0.contains(word) }) {
                    score = 3
                } else {
                    matchesAll = false
                    break
                }
                worst = max(worst, score)
            }
            guard matchesAll else { continue }
            scored.append((name, name == normalized ? 0 : worst))
        }
        // Stable: within a score, keep Apple's order.
        return scored.enumerated()
            .sorted { ($0.element.score, $0.offset) < ($1.element.score, $1.offset) }
            .map(\.element.name)
    }

    // MARK: Loading

    private static let resources = URL(
        fileURLWithPath: "/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources")

    /// Suffixes of script-specific variants (e.g. `character.ar`), which duplicate a base symbol.
    private static let localeSuffixes: Set<String> = [
        "ar", "bn", "el", "gu", "he", "hi", "ja", "km", "kn", "ko", "ml", "mni", "mr",
        "my", "or", "pa", "rtl", "ru", "sat", "si", "ta", "te", "th", "zh",
    ]

    /// Categories that describe rendering features rather than subjects.
    private static let hiddenCategories: Set<String> = ["variable", "multicolor"]

    static func load() -> SymbolCatalog {
        guard let order: [String] = plist("symbol_order"), !order.isEmpty else {
            return fallback
        }
        let names = Set(order)
        let symbols = order.filter { name in
            guard let dot = name.lastIndex(of: ".") else { return true }
            let suffix = String(name[name.index(after: dot)...])
            return !(localeSuffixes.contains(suffix) && names.contains(String(name[..<dot])))
        }
        let categoryList: [[String: String]] = plist("categories") ?? []
        let categories = categoryList.compactMap { entry -> Category? in
            guard let key = entry["key"], let symbol = entry["icon"],
                  !hiddenCategories.contains(key) else { return nil }
            return Category(key: key, symbol: symbol)
        }
        return SymbolCatalog(
            symbols: symbols,
            categories: categories.isEmpty ? [.all] : categories,
            categoriesBySymbol: plist("symbol_categories") ?? [:],
            keywordsBySymbol: plist("symbol_search") ?? [:]
        )
    }

    private static func plist<T>(_ name: String) -> T? {
        guard let data = try? Data(contentsOf: resources.appending(path: "\(name).plist")) else { return nil }
        return (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? T
    }

    /// Used only if the system's symbol list can't be read.
    private static let fallback = SymbolCatalog(
        symbols: [
            "terminal", "command", "bolt", "flame", "leaf", "brain", "gamecontroller", "wifi",
            "speaker.slash", "display", "keyboard", "network", "lock", "globe", "folder", "doc.text",
            "hammer", "wrench.and.screwdriver", "xmark.octagon", "number", "shippingbox", "server.rack",
            "ant", "curlybraces",
        ],
        categories: [.all],
        categoriesBySymbol: [:],
        keywordsBySymbol: [:]
    )
}
