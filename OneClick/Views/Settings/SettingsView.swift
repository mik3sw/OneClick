//
//  SettingsView.swift
//  OneClick
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gearshape") {
                GeneralSettingsView()
            }
            Tab("Menu", systemImage: "switch.2") {
                MenuSettingsView()
            }
            Tab("Custom", systemImage: "terminal") {
                CustomItemsSettingsView()
            }
            Tab("About", systemImage: "info.circle") {
                AboutSettingsView()
            }
        }
        .frame(width: 520, height: 520)
    }
}

#Preview {
    let preferences = Preferences(defaults: UserDefaults(suiteName: "preview")!)
    SettingsView()
        .environment(preferences)
        .environment(SystemController(preferences: preferences))
}
