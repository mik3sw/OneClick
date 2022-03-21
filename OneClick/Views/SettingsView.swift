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


var showOneG : Bool = true
var showTwoG = true
var showThreeG = true
var showFourG = true
var showFiveG = true
var showSixG = true
var showSevenG = true
var showEightG = true
var showNineG = true
var showTenG = true
var showElevenG = true


struct GeneralSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 12.0
    
    
    
    enum BGLightE: String, CaseIterable, Identifiable {
        case bg_default, bg1_light, bg2_light, bg3_light, bg4_light, bg5_light, bg6_light
        var id: Self { self }
    }
    
    enum BGDarkE: String, CaseIterable, Identifiable {
        case bg_default, bg1_dark, bg2_dark, bg3_dark, bg4_dark, bg5_dark, bg6_dark
        var id: Self { self }
    }
    
    @State var selectedLight: BGLightE = .bg_default
    @State var selectedDark: BGDarkE = .bg_default
    
    @AppStorage("light") var lightbackground : String = ""
    @AppStorage("dark") var darkbackground : String = ""
    
    

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
                    Text("Sky").tag(BGLightE.bg3_light)
                    Text("Sea").tag(BGLightE.bg4_light)
                    Text("Green").tag(BGLightE.bg5_light)
                    Text("Pink").tag(BGLightE.bg6_light)
                }.onChange(of: selectedLight) { tag in
                    lightBG = selectedLight.rawValue
                    //UserDefaults.standard.set(selectedLight.rawValue, forKey: "light")
                    
                }.frame(width: 400)
                
                
                Picker("Dark Theme", selection: $selectedDark) {
                    Text("Default").tag(BGDarkE.bg_default)
                    Text("Abstract 1").tag(BGDarkE.bg1_dark)
                    Text("Abstract 2").tag(BGDarkE.bg2_dark)
                    Text("Abstract 3").tag(BGDarkE.bg4_dark)
                    Text("Night").tag(BGDarkE.bg3_dark)
                    Text("Forest").tag(BGDarkE.bg5_dark)
                    Text("City").tag(BGDarkE.bg6_dark)
                    
                }.onChange(of: selectedDark) { tag in
                    darkBG = selectedDark.rawValue
                    //UserDefaults.standard.set(selectedDark.rawValue, forKey: "dark")
                    
                }.frame(width: 400)
                
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
    //@State var showOne: Bool = showOneG
    
    @State var showOne: Bool = !UserDefaults.standard.bool(forKey: "OneT")
    @State var showTwo: Bool = !UserDefaults.standard.bool(forKey: "TwoT")
    @State var showThree: Bool = !UserDefaults.standard.bool(forKey: "ThreeT")
    @State var showFour: Bool = !UserDefaults.standard.bool(forKey: "FourT")
    @State var showFive: Bool = !UserDefaults.standard.bool(forKey: "FiveT")
    @State var showSix: Bool = !UserDefaults.standard.bool(forKey: "SixT")
    @State var showSeven: Bool = !UserDefaults.standard.bool(forKey: "SevenT")
    @State var showEight: Bool = !UserDefaults.standard.bool(forKey: "EightT")
    @State var showNine: Bool = !UserDefaults.standard.bool(forKey: "NineT")
    @State var showTen: Bool = !UserDefaults.standard.bool(forKey: "TenT")
    @State var showEleven: Bool = !UserDefaults.standard.bool(forKey: "ElevenT")
    
    
    

    var body: some View {
        ZStack{
            VStack{
                
                Text("Choose which toggle will be displayed, then hit refresh button \(Image(systemName: "goforward"))")
                
                Divider()
                    .padding(.horizontal, 10.0)
                    .frame(width: 500)
                    
                HStack{
                    
                    VStack{
                        
                        HStack(spacing: 0){
                            Image(systemName: "menubar.dock.rectangle")
                                .padding(.top, 15.0)
                                .padding(.leading, 15.0)
                                .frame(width: 40, alignment: .leading)
                                
                            Text("Desktop files")
                                .fontWeight(.medium)
                                .padding(.top, 15.0)
                                .frame(width: 150, alignment: .leading)
                            
                            Toggle("", isOn: $showOne)
                                .toggleStyle(.switch)
                                .frame(alignment: .leading)
                                .padding(.top, 15.0)
                                .onChange(of: showOne) { value in
                                    //showOneG = showOne
                                    showOne = !showOne
                                    UserDefaults.standard.set(!showOne, forKey: "OneT")
                                }
                        }
                        
                        HStack(spacing: 0){
                                
                                Image(systemName: "dock.rectangle")
                                    .padding(.top, 15.0)
                                    .padding(.leading, 15.0)
                                    .frame(width: 40, alignment: .leading)
                                
                                Text("Hide/show Dock")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                
                                
                                
                                Toggle("", isOn: $showThree)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showThree) { value in
                                        showThree = !showThree
                                        UserDefaults.standard.set(!showThree, forKey: "ThreeT")
                                    }
                                }
                        
                        HStack(spacing: 0){
                                
                                Image(systemName: "battery.50")
                                    .padding(.top, 15.0)
                                    .padding(.leading, 15.0)
                                    .frame(width: 40, alignment: .leading)
                                
                                Text("Battery Saving")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $showFive)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showFive) { value in
                                        showFive = !showFive
                                        UserDefaults.standard.set(!showFive, forKey: "FiveT")
                                    }
                                }
                        
                        HStack(spacing: 0){
                            
                            Image(systemName: "eye")
                                .padding(.top, 15.0)
                                .padding(.leading, 15.0)
                                .frame(width: 40, alignment: .leading)
                                
                                Text("Caffeinate")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $showSeven)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showSeven) { value in
                                        //perform your action here...
                                        showSeven = !showSeven
                                        UserDefaults.standard.set(!showSeven, forKey: "SevenT")
                                    }
                        }
                        
                        
                        
                    }
                    
                    VStack{
                        HStack(spacing: 0){
            //                    folder.fill
                                Image(systemName: "folder.fill")
                                    .padding(.top, 15.0)
                                    .padding(.leading, 15.0)
                                    .frame(width: 40, alignment: .leading)
                                Text("Hidden Files")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $showTwo)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showTwo) { value in
                                        showTwo = !showTwo
                                        UserDefaults.standard.set(!showTwo, forKey: "TwoT")
                                    }
                        }
                        
                        HStack(spacing: 0){
                                
                                Image(systemName: "menubar.rectangle")
                                    .padding(.top, 15.0)
                                    .padding(.leading, 15.0)
                                    .frame(width: 40, alignment: .leading)
                                
                                Text("Hide/show MenuBar")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                
                                
                                
                                Toggle("", isOn: $showFour)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showFour) { value in
                                        showFour = !showFour
                                        UserDefaults.standard.set(!showFour, forKey: "FourT")
                                    }
                                }
                        
                        HStack(spacing: 0){
                                
                                Image(systemName: "moon.stars")
                                    .padding(.top, 15.0)
                                    .padding(.leading, 15.0)
                                    .frame(width: 40, alignment: .leading)
                                
                                Text("Dark Mode")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $showSix)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showSix) { value in
                                        showSix = !showSix
                                        UserDefaults.standard.set(!showSix, forKey: "SixT")
                                    }
                                }
                        
                        HStack(spacing: 0){
                            
                            Image(systemName: "text.and.command.macwindow")
                                .padding(.top, 15.0)
                                .padding(.leading, 15.0)
                                .frame(width: 40, alignment: .leading)
                                
                                Text("Privacy mode")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 150, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $showEight)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: showEight) { value in
                                        //perform your action here...
                                        showEight = !showEight
                                        UserDefaults.standard.set(!showEight, forKey: "EightT")
                                    }
                        }
                        
                        
                    }
                }
                
                Divider()
                    .padding(.horizontal, 10.0)
                    .frame(width: 500)
                    
                
                HStack(spacing: 0){
                    
                    Image(systemName: "trash")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
                        
                        Text("Empty Trash")
                            .fontWeight(.medium)
                            .padding(.top, 15.0)
                            .frame(width: 395, alignment: .leading)
                            
                        
                        Toggle("", isOn: $showNine)
                            .toggleStyle(.switch)
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                            .onChange(of: showNine) { value in
                                //perform your action here...
                                showNine = !showNine
                                UserDefaults.standard.set(!showNine, forKey: "NineT")
                            }
                }
                
                HStack(spacing: 0){
                    
                    Image(systemName: "memorychip")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
                        
                        Text("Memory Cache")
                            .fontWeight(.medium)
                            .padding(.top, 15.0)
                            .frame(width: 395, alignment: .leading)
                            
                        
                        Toggle("", isOn: $showTen)
                            .toggleStyle(.switch)
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                            .onChange(of: showTen) { value in
                                //perform your action here...
                                showTen = !showTen
                                UserDefaults.standard.set(!showTen, forKey: "TenT")
                            }
                }
                
                HStack(spacing: 0){
                    
                    Image(systemName: "photo")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
                        
                        Text("Screenshot")
                            .fontWeight(.medium)
                            .padding(.top, 15.0)
                            .frame(width: 395, alignment: .leading)
                            
                        
                        Toggle("", isOn: $showEleven)
                            .toggleStyle(.switch)
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                            .onChange(of: showEleven) { value in
                                //perform your action here...
                                showEleven = !showEleven
                                UserDefaults.standard.set(!showEleven, forKey: "ElevenT")
                            }
                }
                
                
                
            }
            
            
            
        }
        
    }
    
}



struct AboutSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 15.0
    
    struct Info: Identifiable {
        let infoName: String
        let aboutName: String
        let id = UUID()
    }
    @State private var info = [
        Info(infoName: "Dev", aboutName: "Chavez"),
        Info(infoName: "Mei", aboutName: "Chen"),
        Info(infoName: "Tom", aboutName: "Clark"),
        Info(infoName: "Gita", aboutName: "Kumar"),
    ]
    
    @State private var sortOrder = [KeyPathComparator(\Info.infoName)]
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("About").fontWeight(.medium)
                }
                Text("")
                Text("")
                Text("Thanks for downloading this app ❤️")
                Text("-mik3sw")
                
//                List{
//                    Text("Dev:                      Michele Marcucci")
//                    Text("Status:                   Beta")
//                }
                
//                Table(info, sortOrder: $sortOrder) {
//                        TableColumn("Given Name", value: \.infoName)
//                        TableColumn("Family Name", value: \.aboutName)
//                    }
                
                Link("GitHub", destination: URL(string: "https://github.com/mik3sw/OneClick")!)
                    .buttonStyle(LinkButtonStyle())
                    .padding(.top, 15.0)
            }
            
            
        }.frame(width: 500)
        
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

struct CustomToggleView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 15.0
    @State var enableCustom : Bool = false
    
    var body: some View{
        ZStack{
            VStack(alignment: .leading, spacing: 0){
                HStack(spacing: 0){
                    Toggle("Enable custom toggles", isOn: $enableCustom)
                        .onChange(of: enableCustom) { value in
                            if(value){
                            
                            } else{
                            
                            }
                        }
                        .padding(.leading, 15.0)
                        .padding(.top, 15.0)
                        .padding(.bottom, 10.0)
                        .frame(width: 500, alignment: .leading)
                }
                
            }
            
            
        }.frame(width: 500)
        
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
            
//            ShortcutSettingsView()
//                .tabItem {
//                    Label("Shortcut", systemImage: "command")
//                }
//                .tag(Tabs.about)
            
            CustomToggleView()
                .tabItem{
                    Label("Custom toggles", systemImage: "paintbrush.pointed")
                }
            
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "lightbulb")
                }
                .tag(Tabs.about)
        }
        .padding(20)
        
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
