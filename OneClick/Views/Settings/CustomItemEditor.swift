//
//  CustomItemEditor.swift
//  OneClick
//

import SwiftUI

/// Sheet for creating or editing a custom item.
struct CustomItemEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: CustomItem
    let onSave: (CustomItem) -> Void

    init(item: CustomItem, onSave: @escaping (CustomItem) -> Void) {
        _item = State(initialValue: item)
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $item.name, prompt: Text("VPN"))
                    Picker("Type", selection: $item.kind) {
                        Text("Toggle").tag(CustomItem.Kind.toggle)
                        Text("Button").tag(CustomItem.Kind.action)
                    }
                    .pickerStyle(.segmented)
                    LabeledContent("Icon") {
                        SymbolPicker(selection: $item.symbol)
                    }
                }

                Section {
                    commandField(
                        item.kind == .toggle ? "When turned on" : "Command",
                        text: $item.onCommand,
                        prompt: "open -a Tunnelblick")
                    if item.kind == .toggle {
                        commandField("When turned off", text: $item.offCommand, prompt: "osascript -e 'quit app \"Tunnelblick\"'")
                        commandField("Status check (optional)", text: $item.statusCommand, prompt: "pgrep -q Tunnelblick")
                    }
                } header: {
                    Text("Commands")
                } footer: {
                    Text(item.kind == .toggle
                         ? "Commands run in your login shell. If you add a status check, the toggle is on when it exits with code 0; otherwise OneClick remembers the last state."
                         : "The command runs in your login shell.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
        .frame(width: 500, height: 500)
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
}

#Preview {
    CustomItemEditor(item: CustomItem()) { _ in }
}
