//
//  MenuView.swift
//  OneClick
//
//  Created by Michele Marcucci on 15/12/21.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import SwiftUI


struct MenuView: View {
    
    @State var selected1: Bool = false
    @State var selected2: Bool = false
    @State var selected3: Bool = false
    @State var selected4: Bool = false
    @State var selected5: Bool = false
    @State var selected6: Bool = false
    @State var selected7: Bool = false
    @State var icn: String = "sun.max.fill"
    @State var eye: String = "eye.slash.fill"
    @State var battery: String = "battery.25"

    var body: some View {
        
        
        VStack( alignment: .leading, spacing: 0){
            
            Text("OneClick")
                .font(Font.system(size: 15.0))
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 15.0)
                .padding(.top, 15.0)
            
            Text("Created by mik3sw")
                .fontWeight(.thin)
                .padding(.horizontal, 15.0)
                .padding(.top, 5.0)
                .padding(.bottom, 15.0)
            
            Divider()
                .padding(.horizontal, 10.0)
                .frame(width: 300)
            
            Group {
            HStack(
                spacing: 0){
//                   \(Image(systemName: "sun.max.fill"))
                    Image(systemName: "menubar.dock.rectangle")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
                        
                    Text("Desktop files")
                        .fontWeight(.medium)
                        .padding(.top, 15.0)
                        .frame(width: 200, alignment: .leading)
                        
                    
                    if #available(macOS 11.0, *) {
                        Toggle("", isOn: $selected1)
                            .toggleStyle(.switch)
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                            .onChange(of: selected1) { value in
                                
                                if (value){
                                    comando(arg: hideDesktop)
                                }
                                else{
                                    comando(arg: showDesktop)
                                }
                            }
                    } else {
                        // Fallback on earlier versions
                    }
            }
            
            Text("Hide/show files and folders in your desktop")
                .font(Font.system(size: 12.0))
                .fontWeight(.light)
                .padding(.leading, 15.0)
                .padding(.top, 5.0)
            
                Group{
                    HStack(
                        spacing: 0){
        //                    folder.fill
                            Image(systemName: "folder.fill")
                                .padding(.top, 15.0)
                                .padding(.leading, 15.0)
                                .frame(width: 40, alignment: .leading)
                            Text("Hidden Files")
                                .fontWeight(.medium)
                                .padding(.top, 15.0)
                                .frame(width: 200, alignment: .leading)
                                
                            
                            Toggle("", isOn: $selected2)
                                .toggleStyle(.switch)
                                .frame(alignment: .leading)
                                .padding(.top, 15.0)
                                .onChange(of: selected2) { value in
                                    
                                    if(value){
                                        comando(arg: showHiddenFiles)
                                    }
                                    else{
                                        comando(arg: hideHiddenFiles)
                                    }
                                }
                    }
                    
                    Text("Hide/show hidden files and folders everywhere")
                        .font(Font.system(size: 12.0))
                        .fontWeight(.light)
                        .padding(.leading, 15.0)
                        .padding(.top, 5.0)
                }
            
                
                
                Group{
                    HStack(
                        spacing: 0){
                            
                            Image(systemName: "dock.rectangle")
                                .padding(.top, 15.0)
                                .padding(.leading, 15.0)
                                .frame(width: 40, alignment: .leading)
                            
                            Text("Hide/show dock")
                                .fontWeight(.medium)
                                .padding(.top, 15.0)
                                .frame(width: 200, alignment: .leading)
                                
                            
                            Toggle("", isOn: $selected6)
                                .toggleStyle(.switch)
                                .frame(alignment: .leading)
                                .padding(.top, 15.0)
                                .onChange(of: selected6) { value in
                                    
                                    if(value){
                                        comando(arg: setAutohideDockOn)
                                        
                                    }
                                    else{
                                        comando(arg: setAutohideDockOff)
                                        
                                    }
                                }
                            }
                    
                    Text("Enable/disable dock autohiding")
                        .font(Font.system(size: 12.0))
                        .fontWeight(.light)
                        .padding(.leading, 15.0)
                        .padding(.top, 5.0)
                }
                
                
                HStack(
                    spacing: 0){
                        
                        Image(systemName: battery)
                            .padding(.top, 15.0)
                            .padding(.leading, 15.0)
                            .frame(width: 40, alignment: .leading)
                        
                        Text("Battery Saving")
                            .fontWeight(.medium)
                            .padding(.top, 15.0)
                            .frame(width: 200, alignment: .leading)
                            
                        
                        Toggle("", isOn: $selected4)
                            .toggleStyle(.switch)
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                            .onChange(of: selected4) { value in
                                
                                if(value){
                                    comando(arg: batterySavingOn)
                                    battery = "battery.75"
                                }
                                else{
                                    comando(arg: batterySavingOff)
                                    battery = "battery.25"
                                }
                            }
                        }
                
                Text("Enable/disable battery saving (need root access)")
                    .font(Font.system(size: 12.0))
                    .fontWeight(.light)
                    .padding(.leading, 15.0)
                    .padding(.top, 5.0)
                
                HStack(
                    spacing: 0){
                        
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
                                }
                                else{
                                    comando(arg: darkModeOff)
                                    icn = "sun.max.fill"
                                }
                            }
                        }
                
                Text("Enable/disable dark mode")
                    .font(Font.system(size: 12.0))
                    .fontWeight(.light)
                    .padding(.leading, 15.0)
                    .padding(.top, 5.0)
                
            
            HStack(spacing: 0){
                
                Image(systemName: eye)
                    .padding(.top, 15.0)
                    .padding(.leading, 15.0)
                    .frame(width: 40, alignment: .leading)
                    
                    Text("Caffeinate")
                        .fontWeight(.medium)
                        .padding(.top, 15.0)
                        .frame(width: 200, alignment: .leading)
                        
                    
                    Toggle("", isOn: $selected3)
                        .toggleStyle(.switch)
                        .frame(alignment: .leading)
                        .padding(.top, 15.0)
                        .onChange(of: selected3) { value in
                            //perform your action here...
                            if(value){
                                
                                comando(arg: caffeinateOn)
                                eye = "eye.fill"
                                
                            }else{
                                comando(arg: caffeinateOff)
                                eye = "eye.slash.fill"
                            }
                        }
            }
            
            Text("Prevent Mac from going to sleep")
                .font(Font.system(size: 12.0))
                .fontWeight(.light)
                .padding(.leading, 15.0)
                .padding(.top, 5.0)
                .padding(.bottom, 15.0)
                
            }
            
            
            
            
            
            Group{
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
                                    
                                    
                                    
                                }else{
                                    selected1 = false
                                    selected6 = false
                                    
                                }
                            }
                }
                
                Text("Hide desktop and dock")
                    .font(Font.system(size: 12.0))
                    .fontWeight(.light)
                    .padding(.leading, 15.0)
                    .padding(.top, 5.0)
                    .padding(.bottom, 15.0)
            }
            
            
            
            Divider()
                .padding(.horizontal, 10.0)
                .frame(width: 300)
            
            
            Group{
                
                HStack(spacing: 0){
                    
                    Image(systemName: "trash")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
//                      .renderingMode(.original)
                        
                        Text("Empty Trash")
                            .fontWeight(.medium)
                            .padding(.top, 15.0)
                            .frame(width: 200, alignment: .leading)
                            
                        
                    Button(action: {
                        comando(arg: emptyTrash)
                    }){
                        Text("Clear")
                    }
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                            
                            
                            
                }
                
            }
            
            Group{
                HStack(spacing: 0){
                    
                    Image(systemName: "memorychip")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
//                      .renderingMode(.original)
                        
                        Text("Memory cache")
                            .fontWeight(.medium)
                            .padding(.top, 15.0)
                            .frame(width: 200, alignment: .leading)
                            
                        
                    Button(action: {
                        comando(arg: purgeMemory)
                    }){
                        Text("Clear")
                    }
                            .frame(alignment: .leading)
                            .padding(.top, 15.0)
                }
            }
            
            Group{
                HStack(spacing: 0){
                    
                    Image(systemName: "photo")
                        .padding(.bottom, 15.0)
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
//                      .renderingMode(.original)
                        
                        Text("Screenshot (3s)")
                            .fontWeight(.medium)
                            .padding(.bottom, 15.0)
                            .padding(.top, 15.0)
                            .frame(width: 200, alignment: .leading)
                            
                        
                    Button(action: {
                        comando(arg: screenshot)
                    }){
                        Text("Take")
                    }
                            .frame(alignment: .leading)
                            .padding(.bottom, 15.0)
                            .padding(.top, 15.0)
                }
                
                Divider()
                    .padding(.horizontal, 10.0)
                    .frame(width: 300)
            }
            
            
            
            HStack{
                Link("\(Image(systemName: "link")) GitHub", destination: URL(string: "https://github.com/mik3sw/OneClick")!)
                    .buttonStyle(LinkButtonStyle())
                    .padding(.leading, 15.0)
                    .padding(.top, 15.0)
                    .padding(.bottom, 10.0)
                    .frame(width: 240, alignment: .leading)
                
                Button("Quit", action: {
                    NSApplication.shared.terminate(self)
                })
                .padding(.top, 15.0)
                .padding(.bottom, 10.0)
                .frame(alignment: .leading)
                
            }
            
//            defaults write com.apple.finder CreateDesktop false killall Finder
            
            
        }
        
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
