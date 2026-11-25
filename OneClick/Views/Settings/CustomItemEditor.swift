//
//  CustomItemEditor.swift
//  OneClick
//

import SwiftUI

/// Sheet for creating or editing a custom item.
struct CustomItemEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: CustomItem
    let existingGroups: [String]
    let onSave: (CustomItem) -> Void

    init(item: CustomItem, existingGroups: [String] = [], onSave: @escaping (CustomItem) -> Void) {
        _item = State(initialValue: item)
        self.existingGroups = existingGroups
        self.onSave = onSave
    }

    private static let timeouts = [0, 5, 10, 30, 60, 300]
    private static let refreshIntervals = [5, 10, 30, 60, 300, 900, 3600]

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $item.name, prompt: Text(namePrompt))
                    Picker("Type", selection: $item.kind) {
                        ForEach(CustomItem.Kind.allCases, id: \.self) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    LabeledContent("Icon") {
                        SymbolPicker(selection: $item.symbol)
                    }
                    LabeledContent("Group") {
                        HStack(spacing: 4) {
                            TextField("Group", text: $item.group, prompt: Text("Custom"))
                                .labelsHidden()
                            if !existingGroups.isEmpty {
                                Menu {
                                    ForEach(existingGroups, id: \.self) { group in
                                        Button(group) { item.group = group }
                                    }
                                } label: {
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .menuStyle(.borderlessButton)
                                .menuIndicator(.hidden)
                                .fixedSize()
                                .help("Choose an existing group")
                            }
                        }
                    }
                }

                Section {
                    commands
                } header: {
                    Text("Commands")
                } footer: {
                    Text(commandsFooter)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Options") {
                    Toggle(isOn: $item.runAsAdmin) {
                        Text("Run as administrator")
                        Text("Asks for Touch ID or your password each time.")
                    }
                    if item.kind != .info {
                        Toggle(isOn: $item.requiresConfirmation) {
                            Text("Ask for confirmation")
                            Text("Click twice in the panel to run it.")
                        }
                    }
                    if item.kind == .action {
                        Toggle(isOn: $item.copiesOutput) {
                            Text("Copy output to clipboard")
                            Text("Copies what the command prints when it succeeds.")
                        }
                    }
                    if item.kind == .info {
                        Picker("Refresh every", selection: $item.refreshInterval) {
                            ForEach(Self.options(Self.refreshIntervals, including: item.refreshInterval), id: \.self) {
                                Text(Self.duration($0)).tag($0)
                            }
                        }
                    }
                    Picker("Stop after", selection: $item.timeout) {
                        ForEach(Self.options(Self.timeouts, including: item.timeout), id: \.self) { seconds in
                            Text(seconds == 0 ? "No limit" : Self.duration(seconds)).tag(seconds)
                        }
                    }
                    LabeledContent("Keyboard shortcut") {
                        ShortcutRecorder(shortcut: $item.shortcut)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    onSave(item)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.glassProminent)
                .disabled(!item.isValid)
            }
            .padding()
        }
        .frame(width: 520, height: 640)
    }

    @ViewBuilder
    private var commands: some View {
        switch item.kind {
        case .toggle:
            commandField("When turned on", text: $item.onCommand, prompt: "open -a Tunnelblick")
            commandField("When turned off", text: $item.offCommand, prompt: "osascript -e 'quit app \"Tunnelblick\"'")
            commandField("Status check (optional)", text: $item.statusCommand, prompt: "pgrep -q Tunnelblick")
        case .action:
            commandField("Command", text: $item.onCommand, prompt: "open -a Tunnelblick")
        case .info:
            commandField("Command", text: $item.onCommand, prompt: "curl -s https://api.ipify.org")
        }
    }

    private var namePrompt: String {
        switch item.kind {
        case .toggle: "VPN"
        case .action: "Flush DNS"
        case .info: "Public IP"
        }
    }

    private var commandsFooter: String {
        switch item.kind {
        case .toggle:
            "Commands run in your login shell. If you add a status check, the toggle is on when it exits with code 0; otherwise OneClick remembers the last state. The status check always runs without administrator rights."
        case .action:
            "The command runs in your login shell."
        case .info:
            "The tile shows what the command prints, and refreshes while the panel is open. Click the tile to copy the text."
        }
    }

    private func commandField(_ title: String, text: Binding<String>, prompt: String) -> some View {
        LabeledContent(title) {
            TextField(title, text: text, prompt: Text(prompt), axis: .vertical)
                .labelsHidden()
                .multilineTextAlignment(.leading)
                .font(.body.monospaced())
                .lineLimit(1...4)
                .autocorrectionDisabled()
        }
    }

    /// The preset values, plus a custom one from an imported item.
    private static func options(_ presets: [Int], including value: Int) -> [Int] {
        presets.contains(value) ? presets : (presets + [value]).sorted()
    }

    private static func duration(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide))
    }
}

#Preview {
    CustomItemEditor(item: CustomItem()) { _ in }
}
