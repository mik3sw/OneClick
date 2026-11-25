//
//  SymbolPicker.swift
//  OneClick
//

import SwiftUI

/// A button showing the chosen SF Symbol that opens a searchable browser of all symbols.
struct SymbolPicker: View {
    @Binding var selection: String
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: selection)
                    .frame(width: 20)
                Text(selection)
                    .font(.body.monospaced())
                    .lineLimit(1)
                    .truncationMode(.middle)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .popover(isPresented: $isPresented, arrowEdge: .trailing) {
            SymbolBrowser(selection: $selection) { isPresented = false }
        }
    }
}

/// Grid of every SF Symbol with search and categories.
struct SymbolBrowser: View {
    @Binding var selection: String
    let onPick: () -> Void

    @State private var catalog: SymbolCatalog?
    @State private var results: [String] = []
    @State private var query = ""
    @State private var category = SymbolCatalog.Category.all
    @State private var hovered: String?
    @FocusState private var searchFocused: Bool

    /// Loaded once per launch; reading the system plists takes a few milliseconds.
    private static var cachedCatalog: SymbolCatalog?

    private let columns = [GridItem(.adaptive(minimum: 40, maximum: 44), spacing: 4)]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("Search symbols", text: $query, prompt: Text("Search \(results.count) symbols"))
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFocused)
                if let catalog, catalog.categories.count > 1 {
                    Picker("Category", selection: $category) {
                        ForEach(catalog.categories) { category in
                            Label(category.title, systemImage: category.symbol).tag(category)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }
            .padding(10)

            Divider()

            Group {
                if catalog == nil {
                    ProgressView()
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    grid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            Text(hovered ?? selection)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .frame(width: 460, height: 440)
        .task {
            if Self.cachedCatalog == nil {
                Self.cachedCatalog = await Task.detached(priority: .userInitiated) { SymbolCatalog.load() }.value
            }
            catalog = Self.cachedCatalog
            updateResults()
            searchFocused = true
        }
        .onChange(of: query) { updateResults() }
        .onChange(of: category) { updateResults() }
    }

    private var grid: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(results, id: \.self) { name in
                        SymbolCell(name: name, isSelected: name == selection, isHovered: name == hovered) {
                            selection = name
                            onPick()
                        }
                        .onHover { inside in
                            if inside { hovered = name } else if hovered == name { hovered = nil }
                        }
                        .id(name)
                    }
                }
                .padding(10)
            }
            .onAppear {
                proxy.scrollTo(selection, anchor: .center)
            }
        }
    }

    private func updateResults() {
        results = catalog?.symbols(in: category, matching: query) ?? []
    }
}

private struct SymbolCell: View {
    let name: String
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 17))
                .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                .frame(width: 40, height: 40)
                .background(background, in: .rect(cornerRadius: 8))
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help(name)
        .accessibilityLabel(name)
    }

    private var background: AnyShapeStyle {
        if isSelected { return AnyShapeStyle(Color.accentColor) }
        if isHovered { return AnyShapeStyle(.fill.secondary) }
        return AnyShapeStyle(.clear)
    }
}

#Preview {
    SymbolBrowser(selection: .constant("terminal")) {}
}
