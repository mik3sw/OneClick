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
                                //perform your action here...
                                if (value){
                                    comando(arg: "defaults write com.apple.finder CreateDesktop false ; killall Finder")
                                    // comando(arg: "killall Finder")
                                }
                                else{
                                    comando(arg: "defaults write com.apple.finder CreateDesktop true ; killall Finder")
                                    // comando(arg: "killall Finder")
                                    
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
                            //perform your action here...
                            if(value){
                                
                                comando(arg: "defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder")
                                // comando(arg: "killall Finder")
                                
                            }else{
                                comando(arg: "defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder")
                                //comando(arg: "killall Finder")
                            }
                        }
                
            }
            
            Text("Hide/show hidden files and folders everywhere")
                .font(Font.system(size: 12.0))
                .fontWeight(.light)
                .padding(.leading, 15.0)
                .padding(.top, 5.0)
                
                
            
                HStack(
                    spacing: 0){
                        
                        Image(systemName: "battery.75")
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
                                //perform your action here...
                                if(value){
                                    
                                    comando(arg: "osascript -e 'do shell script \"pmset -a lowpowermode 1\" with administrator privileges'")
                                    // comando(arg: "killall Finder")
                                    
                                    
                                }else{
                                    comando(arg: "osascript -e 'do shell script \"pmset -a lowpowermode 0\" with administrator privileges'")
                                    //comando(arg: "killall Finder")
                                
                                }
                            }
                    
                }
                
                Text("Enable/disable battery saving (need root access)")
                    .font(Font.system(size: 12.0))
                    .fontWeight(.light)
                    .padding(.leading, 15.0)
                    .padding(.top, 5.0)
                
            
            HStack(spacing: 0){
                
                Image(systemName: "eye.fill")
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
                                
                                comando(arg: "caffeinate")
                                // comando(arg: "killall Finder")
                                
                            }else{
                                comando(arg: "killall caffeinate")
                                //comando(arg: "killall Finder")
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
            
            
            
            
            
            Divider()
                .padding(.horizontal, 10.0)
                .frame(width: 300)
            
            HStack{
                Link("\(Image(systemName: "link")) GitHub", destination: URL(string: "https://www.github.com")!)
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
