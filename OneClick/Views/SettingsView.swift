//
//  SettingsView.swift
//  OneClick
//
//  Created by Michele Marcucci on 04/03/22.
//  Copyright © 2022 Golden Chopper. All rights reserved.
//

import SwiftUI
import LaunchAtLogin

var darkBG = ""
var lightBG = ""
var bgPath = ""


struct GeneralSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 12.0
    
    
    
    enum BGLightE: String, CaseIterable, Identifiable {
        case bg_default, bg1_light, bg2_light, bg3_light, bg4_light
        var id: Self { self }
    }
    
    enum BGDarkE: String, CaseIterable, Identifiable {
        case bg_default, bg1_dark, bg2_dark, bg3_dark, bg4_dark
        var id: Self { self }
    }
    
    @State var selectedLight: BGLightE = .bg_default
    @State var selectedDark: BGDarkE = .bg_default
    

    var body: some View {
        
        ZStack{
            VStack{
                
//                Button("Choose Folder") {
//                    let openPanel = NSOpenPanel()
//                    openPanel.prompt = "Select File"
//                    openPanel.allowsMultipleSelection = false
//                    openPanel.canChooseDirectories = false
//                    openPanel.canCreateDirectories = false
//                    openPanel.canChooseFiles = true
//                    openPanel.allowedFileTypes = ["png","jpg","jpeg"]
//                    openPanel.begin { (result) -> Void in
//                        if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
//                            let selectedPath = openPanel.url!.path
//                            print(selectedPath)
//                            bgPath = selectedPath
//                        }
//                    }
//
//                }
                VStack{
                    HStack{
                        Image(systemName: "paintbrush.fill")
                        Text("Themes")
                            .fontWeight(.medium)
                            .frame(width: 445, alignment: .leading)
                            
                    }
                    Divider()
                        .padding(.horizontal, 10.0)
                        .frame(width: 500)
                    
                    Text("This need a refresh to be effective (use dark mode switch)")
                        .fontWeight(.light)
                        .frame(width: 460, alignment: .leading)
                        
                }
                
                
                Picker("Light Theme", selection: $selectedLight) {
                    Text("Default").tag(BGLightE.bg_default)
                    Text("Mountain").tag(BGLightE.bg1_light)
                    Text("Yellow").tag(BGLightE.bg2_light)
                    Text("Sunrise").tag(BGLightE.bg3_light)
                    Text("Sunset").tag(BGLightE.bg4_light)
                }.onChange(of: selectedLight) { tag in
                    lightBG = selectedLight.rawValue
                    
                }
                
                
                Picker("Dark Theme", selection: $selectedDark) {
                    Text("Default").tag(BGDarkE.bg_default)
                    Text("Abstract 1").tag(BGDarkE.bg1_dark)
                    Text("Abstract 2").tag(BGDarkE.bg2_dark)
                    Text("Abstract 3").tag(BGDarkE.bg4_dark)
                    Text("Night").tag(BGDarkE.bg3_dark)
                    
                }.onChange(of: selectedDark) { tag in
                    darkBG = selectedDark.rawValue
                    
                }
                
                Text("")
                Text("")
                
                
                VStack{
                    HStack{
                        Image(systemName: "gear")
                        Text("Login Settings")
                            .fontWeight(.medium)
                            .frame(width: 445, alignment: .leading)
                            
                    }
                    Divider()
                        .padding(.horizontal, 10.0)
                        .frame(width: 500)
                        
                }
                
                
//                Text("Selected Themes: \(selectedLight.rawValue) \(selectedDark.rawValue)")
                
                
                
                LaunchAtLogin.Toggle {
                            Text("Launch at login")
                        }
                    .padding(.leading, 15.0)
                    .padding(.top, 5.0)
                    .padding(.bottom, 10.0)
                    .frame(width: 500, alignment: .leading)
            }
        }
        
        
    }
    
    
}


struct AdvancedSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 15.0

    var body: some View {
        ZStack{
            HStack{
                Text("Work in progress!")
                Image(systemName: "wand.and.stars")
            }
            
        }
        
    }
}



struct AboutSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 15.0

    var body: some View {
        ZStack{
            HStack{
                Text("About")
                Image(systemName: "wand.and.stars")
            }
            
        }
        
    }
}

struct ShortcutSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 15.0

    var body: some View {
        ZStack{
            HStack{
                Text("Shortcut")
                Image(systemName: "wand.and.stars")
            }
            // https://github.com/sindresorhus/KeyboardShortcuts
            
        }
        
    }
}


struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, advanced, about
    }
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            AdvancedSettingsView()
                .tabItem {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                .tag(Tabs.advanced)
            
            ShortcutSettingsView()
                .tabItem {
                    Label("Shortcut", systemImage: "command")
                }
                .tag(Tabs.about)
            
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "lightbulb")
                }
                .tag(Tabs.about)
        }
        .padding(20)
        .frame(width: 500, height: 250)
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
