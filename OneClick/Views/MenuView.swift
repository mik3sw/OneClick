//
//  MenuView.swift
//  OneClick
//
//  Created by Michele Marcucci on 15/12/21.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import SwiftUI
import LaunchAtLogin




struct MenuView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showSettings = false
    @State var bg = whichBG()
    @State var refreshView: Bool = false
    
    // toggle status based on system settings
    @State var selected1: Bool = (comandoOut(arg: statusDesktop)).contains("false")
    @State var selected2: Bool = (comandoOut(arg: statusFiles)).contains("1")
    @State var selected3: Bool = false
    @State var selected4: Bool = (comandoOut(arg: statusBatterySaving)).contains("lowpowermode         1")
    @State var selected5: Bool = (comandoOut(arg: darkModeStatus)).contains("true")
    @State var selected6: Bool = (comandoOut(arg: statusAutohideDock)).contains("true")
    @State var selected7: Bool = false
    @State var selected8: Bool = (comandoOut(arg: statusAutohideMenuBar)).contains("true")
    
    @State var icn: String = "sun.max.fill"
    //@State var eye: String = "eye.slash.fill"
    //@State var battery: String = "battery.25"
    
    @AppStorage("OneT") var showOne: Bool = true
    @AppStorage("TwoT") var showTwo: Bool = true
    @AppStorage("ThreeT") var showThree: Bool = true
    @AppStorage("FourT") var showFour: Bool = true
    @AppStorage("FiveT") var showFive: Bool = true
    @AppStorage("SixT") var showSix: Bool = true
    @AppStorage("SevenT") var showSeven: Bool = true
    @AppStorage("EightT") var showEight: Bool = true
    @AppStorage("NineT") var showNine: Bool = true
    @AppStorage("TenT") var showTen: Bool = true
    @AppStorage("ElevenT") var showEleven: Bool = true
    
    //@AppStorage("FiveT") var showFive: Bool = true
    
    
    var body: some View {
        
        ZStack{
            VStack( alignment: .leading, spacing: 0){
                
                // Header
                HStack{
                    Text("OneClick")
                        .font(Font.system(size: 15.0))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 15.0)
                        .padding(.top, 15.0)
                        .frame(width: 245, alignment: .leading)
                    
                    Button(action:{
                        showSettings.toggle()
                    }){
                        Image(systemName: "gear")
                    }
                    .font(Font.system(size: 15.0))
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 15.0)
                    .padding(.top, 15.0)
                    .onChange(of: showSettings) { value in
                        
                        if (value){
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                        }
                    }
                    
                }
                
                
                Text("Created by mik3sw")
                    .fontWeight(.thin)
                    .padding(.horizontal, 15.0)
                    .padding(.top, 5.0)
                    .padding(.bottom, 15.0)
                
                
                
                Divider()
                    .padding(.horizontal, 10.0)
                    .frame(width: 300)
                
                Group {
                    
                    
                    // ToggleViews
                    
                    if !UserDefaults.standard.bool(forKey: "OneT") {
                        ToggleView("Desktop Files", "menubar.dock.rectangle", "Hide/show files and folders in your desktop", hideDesktop, showDesktop, selected1)
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "TwoT"){
                        ToggleView("Hidden files", "folder.fill", "Hide/show hidden files and folders everywhere", showHiddenFiles, hideHiddenFiles, selected2)
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "ThreeT"){
                        ToggleView("Hide/show Dock", "dock.rectangle", "Enable/disable dock autohiding", setAutohideDockOn, setAutohideDockOff, selected6)
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "FourT"){
                        ToggleView("Hide/show MenuBar", "menubar.rectangle", "Enable/disable menubar autohiding", setAutohideMenuBarOn, setAutohideMenuBarOff, selected8)
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "FiveT"){
                        ToggleViewAnimated("Battery Saving", "battery.75", "battery.25", "Enable/disable battery saving (need root access)", batterySavingOn, batterySavingOff, selected4)
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "SixT") {
                        // Dark mode è particolare devo vederla più tardi
                        HStack(spacing: 0){
                                
                                Image(systemName: icn)
                                    .padding(.top, 15.0)
                                    .padding(.leading, 15.0)
                                    .frame(width: 40, alignment: .leading)
                                
                                Text("Dark Mode")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 200, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $selected5)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: selected5) { value in
                                        
                                        if(value){
                                            comando(arg: darkModeOn)
                                            icn = "moon.stars.fill"
                                            bg = darkBG
                                        }
                                        else{
                                            comando(arg: darkModeOff)
                                            icn = "sun.max.fill"
                                            bg = lightBG
                                        }
                                    }
                                }
                        
                        Text("Enable/disable dark mode")
                            .font(Font.system(size: 12.0))
                            .fontWeight(.light)
                            .padding(.leading, 15.0)
                            .padding(.top, 5.0)
                    }
                    
                    
                    if !UserDefaults.standard.bool(forKey: "SevenT"){
                        ToggleViewAnimated("Caffeinate", "eye.fill", "eye.slash.fill", "Prevent Mac from going to sleep", caffeinateOn, caffeinateOff, selected3)
                    }
                    Text("")
                }
                
                Group{
                    // Macro che attiva più comandi insieme, particolare non la toccherei
                    if !UserDefaults.standard.bool(forKey: "EightT") {
                        Divider()
                            .padding(.horizontal, 10.0)
                            .frame(width: 300)
                        
                        HStack(spacing: 0){
                            
                            Image(systemName: "text.and.command.macwindow")
                                .padding(.top, 15.0)
                                .padding(.leading, 15.0)
                                .frame(width: 40, alignment: .leading)
                                
                                Text("Privacy mode")
                                    .fontWeight(.medium)
                                    .padding(.top, 15.0)
                                    .frame(width: 200, alignment: .leading)
                                    
                                
                                Toggle("", isOn: $selected7)
                                    .toggleStyle(.switch)
                                    .frame(alignment: .leading)
                                    .padding(.top, 15.0)
                                    .onChange(of: selected7) { value in
                                        //perform your action here...
                                        if(value){
                                            selected1 = true
                                            selected6 = true
                                            selected8 = true
                                            
                                        }else{
                                            selected1 = false
                                            selected6 = false
                                            selected8 = false
                                            
                                        }
                                    }
                        }
                        
                        Text("Hide desktop, dock and menubar")
                            .font(Font.system(size: 12.0))
                            .fontWeight(.light)
                            .padding(.leading, 15.0)
                            .padding(.top, 5.0)
                            .padding(.bottom, 15.0)
                    }
                    
                }
                
                Divider()
                    .padding(.horizontal, 10.0)
                    .frame(width: 300)
                
                
                Group{
                    // ButtonViews
                    
                    if !UserDefaults.standard.bool(forKey: "NineT") {
                        ButtonView("Empty Trash", "trash", emptyTrash, "Clear")
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "TenT") {
                        ButtonView("Memory cache", "memorychip", purgeMemory, "Clear")
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "ElevenT") {
                        ButtonView("Screenshot (3s)", "photo", screenshot, "Take")
                    }
                    
                    Text("")
                    
                    Divider()
                        .padding(.horizontal, 10.0)
                        .frame(width: 300)
                    
                }
                
                
                Group{
                    // Footer
                    HStack{
                        
                        Button(action:{
                            refreshView.toggle()
                        }){
                            Image(systemName: "goforward")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 15.0)
                        .padding(.top, 15.0)
                        .padding(.bottom, 10.0)
                        .onChange(of: refreshView) { value in
                            
                            refreshView = !refreshView
                        }
//                        LaunchAtLogin.Toggle {
//                                    Text("Launch at login")
//                                }
//                            .padding(.leading, 15.0)
//                            .padding(.top, 15.0)
//                            .padding(.bottom, 10.0)
//                            .frame(width: 240, alignment: .leading)
                        Text("")
                            .padding(.leading, 15.0)
                            .padding(.top, 15.0)
                            .padding(.bottom, 10.0)
                            .frame(width: 200, alignment: .leading)
                        
                        
                        
                        Button("Quit", action: {
                            NSApplication.shared.terminate(self)
                        })
                        .padding(.top, 15.0)
                        .padding(.bottom, 10.0)
                        .frame(alignment: .leading)
                    }
                }
                
                
            }
            
            
            //if showSettings{
            //    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            //}
            
            
        }.background(
            Image(bg)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 360, height: 800)
                .blur(radius: 20)
        )
        .onChange(of: colorScheme) { value in
            bg = whichBG()
        }
            
        
        
    }
    
    
}


