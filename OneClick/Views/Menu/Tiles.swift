//
//  Tiles.swift
//  OneClick
//

import SwiftUI

/// A Control Center–style switch: a round glyph that fills with the accent color when on.
struct ToggleTile: View {
    let title: String
    let symbol: String
    let isOn: Bool
    var isBusy = false
    /// Replaces the On/Off label, e.g. for buttons that have no state.
    var subtitle: String?
    var tint: Color = .accentColor
    var help = ""
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                TileGlyph(symbol: symbol, isOn: isOn, isBusy: isBusy, tint: tint)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                    Text(subtitle ?? (isOn ? "On" : "Off"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
        .disabled(isBusy)
        .help(help)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
        .animation(.snappy, value: isOn)
    }
}

/// A compact square button for one-shot actions.
struct ActionTile: View {
    let title: String
    let symbol: String
    var isBusy = false
    var isDestructivePending = false
    var help = ""
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                TileGlyph(symbol: symbol, isOn: isDestructivePending, isBusy: isBusy, tint: .red)
                Text(isDestructivePending ? "Confirm" : title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(isDestructivePending ? .red : .primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
        .disabled(isBusy)
        .help(help)
        .animation(.snappy, value: isDestructivePending)
    }
}

/// The round icon used by every tile.
struct TileGlyph: View {
    let symbol: String
    let isOn: Bool
    var isBusy = false
    var tint: Color = .accentColor

    var body: some View {
        ZStack {
            Circle()
                .fill(isOn ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(.fill.tertiary))
            if isBusy {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isOn ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    VStack {
        HStack {
            ToggleTile(title: "Dark Mode", symbol: "moon.fill", isOn: true) {}
            ToggleTile(title: "Hidden Files", symbol: "eye.slash", isOn: false) {}
        }
        HStack {
            ActionTile(title: "Empty Trash", symbol: "trash") {}
            ActionTile(title: "Free Memory", symbol: "memorychip", isBusy: true) {}
            ActionTile(title: "Screenshot", symbol: "camera.viewfinder", isDestructivePending: true) {}
        }
    }
    .padding()
    .frame(width: 340)
}
