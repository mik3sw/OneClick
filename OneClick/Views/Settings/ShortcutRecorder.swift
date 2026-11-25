//
//  ShortcutRecorder.swift
//  OneClick
//

import AppKit
import SwiftUI

/// A button that records a global keyboard shortcut.
/// Click it, then press the keys. Esc cancels; Delete removes the shortcut.
struct ShortcutRecorder: View {
    @Binding var shortcut: HotKey?
    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 4) {
            Button {
                isRecording ? stopRecording() : startRecording()
            } label: {
                Text(label)
                    .font(shortcut == nil || isRecording ? .callout : .callout.monospaced())
                    .foregroundStyle(shortcut == nil && !isRecording ? .secondary : .primary)
                    .frame(minWidth: 84)
            }
            .buttonStyle(.bordered)
            .tint(isRecording ? .accentColor : nil)
            .help(isRecording ? "Press a key combination. Esc cancels, Delete removes the shortcut." : "Record a global keyboard shortcut")

            if let shortcut, !isRecording, HotKeyCenter.shared.conflicts.contains(shortcut) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .help("macOS or another app already uses \(shortcut.displayString). Choose a different shortcut.")
            }

            if shortcut != nil, !isRecording {
                Button("Remove Shortcut", systemImage: "xmark.circle.fill") {
                    shortcut = nil
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Remove shortcut")
            }
        }
        .onDisappear(perform: stopRecording)
    }

    private var label: String {
        if isRecording { return "Type Shortcut…" }
        return shortcut?.displayString ?? "Record Shortcut"
    }

    private func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        // Existing shortcuts would swallow the keys before this monitor sees them.
        HotKeyCenter.shared.suspend()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handle(event)
            return nil
        }
    }

    private func handle(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(HotKey.relevantModifiers)
        switch Int(event.keyCode) {
        case 53 where flags.isEmpty: // Esc
            stopRecording()
        case 51 where flags.isEmpty, 117 where flags.isEmpty: // Delete, Forward Delete
            shortcut = nil
            stopRecording()
        default:
            if let recorded = HotKey(event: event) {
                shortcut = recorded
                stopRecording()
            } else {
                NSSound.beep()
            }
        }
    }

    private func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        HotKeyCenter.shared.resume()
    }
}
