//
//  MenuContentView.swift
//  OneClick
//

import SwiftUI

/// The panel shown when clicking the menu bar icon.
struct MenuContentView: View {
    @Environment(Preferences.self) private var preferences
    @Environment(SystemController.self) private var system
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var confirmingEmptyTrash = false
    @State private var confirmationReset: Task<Void, Never>?

    private let twoColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    private let threeColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            GlassEffectContainer(spacing: 8) {
                VStack(spacing: 12) {
                    if !preferences.visibleToggles.isEmpty {
                        LazyVGrid(columns: twoColumns, spacing: 8) {
                            ForEach(preferences.visibleToggles) { feature in
                                ToggleTile(
                                    title: feature.title,
                                    symbol: feature.symbol(isOn: system.isOn(feature)),
                                    isOn: system.isOn(feature),
                                    isBusy: system.isBusy(feature),
                                    help: feature.summary
                                ) {
                                    system.toggle(feature)
                                }
                            }
                        }
                    }

                    if !preferences.visibleActions.isEmpty {
                        LazyVGrid(columns: threeColumns, spacing: 8) {
                            ForEach(preferences.visibleActions) { feature in
                                ActionTile(
                                    title: feature.title,
                                    symbol: feature.symbol(isOn: false),
                                    isBusy: system.isBusy(feature),
                                    isDestructivePending: feature == .emptyTrash && confirmingEmptyTrash,
                                    help: feature.summary
                                ) {
                                    run(feature)
                                }
                            }
                        }
                    }

                    if !preferences.customItems.isEmpty {
                        customSection
                    }
                }
            }

            if let error = system.error {
                ErrorBanner(notice: error) {
                    system.error = nil
                } openSettings: { url in
                    openURL(url)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(14)
        .frame(width: 340)
        .animation(.snappy, value: system.error)
        .onAppear { system.refresh() }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("OneClick")
                .font(.headline)
            Spacer()
            Button("Settings", systemImage: "gearshape") {
                dismiss()
                NSApp.activate()
                openSettings()
            }
            .help("Settings")
            Button("Quit", systemImage: "power") {
                NSApp.terminate(nil)
            }
            .help("Quit OneClick")
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.regular)
        .padding(.leading, 4)
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            LazyVGrid(columns: twoColumns, spacing: 8) {
                ForEach(preferences.customItems) { item in
                    let done = system.didJustComplete(item)
                    ToggleTile(
                        title: item.name,
                        symbol: done ? "checkmark" : item.symbol,
                        isOn: done || (item.kind == .toggle && system.isOn(item)),
                        isBusy: system.isBusy(item),
                        subtitle: item.kind == .action ? (done ? "Done" : "Run") : nil,
                        tint: done ? .green : .accentColor,
                        help: item.onCommand
                    ) {
                        system.activate(item)
                    }
                }
            }
        }
    }

    private func run(_ feature: Feature) {
        switch feature {
        case .emptyTrash where !confirmingEmptyTrash:
            // Ask for a second click before erasing anything.
            confirmingEmptyTrash = true
            confirmationReset?.cancel()
            confirmationReset = Task {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                confirmingEmptyTrash = false
            }
        case .emptyTrash:
            confirmationReset?.cancel()
            confirmingEmptyTrash = false
            system.run(feature)
        case .screenshot:
            // Close the panel so it isn't in the picture.
            dismiss()
            system.run(feature)
        default:
            system.run(feature)
        }
    }
}

/// An inline error message with an optional shortcut to System Settings.
struct ErrorBanner: View {
    let notice: ErrorNotice
    let onDismiss: () -> Void
    let openSettings: (URL) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 6) {
                Text(notice.message)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                if let url = notice.settingsURL {
                    Button("Open System Settings") { openSettings(url) }
                        .buttonStyle(.glass)
                        .controlSize(.small)
                }
            }
            Spacer(minLength: 0)
            Button("Dismiss", systemImage: "xmark", action: onDismiss)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .glassEffect(.regular.tint(.yellow.opacity(0.15)), in: .rect(cornerRadius: 14))
    }
}
