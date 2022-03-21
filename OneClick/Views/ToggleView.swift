//
//  ToggleView.swift
//  OneClick
//
//  Created by Michele Marcucci on 21/03/22.
//  Copyright © 2022 Golden Chopper. All rights reserved.
//

import SwiftUI


struct ToggleView: View {
    @State var selected : Bool
    var name : String
    var description : String
    var icon : String
    var commandTrue : String
    var commandFalse : String
    
    // Generic Toggle View
    
    init(_ name: String, _ icon: String, _ description: String, _ commandTrue: String, _ commandFalse: String ,_ selected: Bool) {
        self.name = name
        self.icon = icon
        self.description = description
        self.commandTrue = commandTrue
        self.commandFalse = commandFalse
        self.selected = selected
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0){
                Image(systemName: "\(icon)")
                     .padding(.top, 15.0)
                     .padding(.leading, 15.0)
                     .frame(width: 40, alignment: .leading)
                                                
                Text("\(name)")
                     .fontWeight(.medium)
                     .padding(.top, 15.0)
                     .frame(width: 200, alignment: .leading)
                                                
                                            
                Toggle("", isOn: $selected)
                    .toggleStyle(.switch)
                    .frame(alignment: .leading)
                    .padding(.top, 15.0)
                    .onChange(of: selected) { value in
                        if (value){
                            comando(arg: "\(commandTrue)")
                        } else{
                            comando(arg: "\(commandFalse)")
                        }
                    }
            }
                                
            Text("\(description)")
                .font(Font.system(size: 12.0))
                .fontWeight(.light)
                .padding(.top, 5.0)
                .padding(.leading, 15.0)
            
            
        }
    }
}

struct ToggleViewAnimated: View {
    
    @State var selected : Bool
    var name : String
    var description : String
    var icon1 : String
    var icon2 : String
    @State var icon : String
    var commandTrue : String
    var commandFalse : String
    
    // Generic Toggle View
    
    init(_ name: String, _ icon1: String, _ icon2: String, _ description: String, _ commandTrue: String, _ commandFalse: String ,_ selected: Bool) {
        self.name = name
        self.icon1 = icon1
        self.icon2 = icon2
        self.description = description
        self.commandTrue = commandTrue
        self.commandFalse = commandFalse
        self.selected = selected
        
        if selected {
            self.icon = icon1
        } else {
            self.icon = icon2
        }
        
    }
    
    var body: some View{
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: 0){
                    
                    Image(systemName: "\(icon)")
                        .padding(.top, 15.0)
                        .padding(.leading, 15.0)
                        .frame(width: 40, alignment: .leading)
                    
                    Text("\(name)")
                        .fontWeight(.medium)
                        .padding(.top, 15.0)
                        .frame(width: 200, alignment: .leading)
                        
                    
                    Toggle("", isOn: $selected)
                        .toggleStyle(.switch)
                        .frame(alignment: .leading)
                        .padding(.top, 15.0)
                        .onChange(of: selected) { value in
                            
                            if(value){
                                comando(arg: commandTrue)
                                icon = icon1
                            }
                            else{
                                comando(arg: commandFalse)
                                icon = icon2
                            }
                        }
                    }
            
            Text("\(description)")
                .font(Font.system(size: 12.0))
                .fontWeight(.light)
                .padding(.leading, 15.0)
                .padding(.top, 5.0)
        }
    }
}

struct ButtonView: View {
    
    var name : String
    var icon: String
    var command: String
    var buttonText: String
    
    
    init(_ name: String, _ icon: String, _ command: String, _ buttonText: String){
        self.name = name
        self.icon = icon
        self.command = command
        self.buttonText = buttonText
    }
    
    var body: some View{
        HStack(spacing: 0){
            
            Image(systemName: "\(icon)")
                .padding(.top, 15.0)
                .padding(.leading, 15.0)
                .frame(width: 40, alignment: .leading)
//                      .renderingMode(.original)
                
                Text("\(name)")
                    .fontWeight(.medium)
                    .padding(.top, 15.0)
                    .frame(width: 200, alignment: .leading)
                    
                
            Button(action: {
                comando(arg: command)
            }){
                Text("\(buttonText)")
            }
                    .frame(alignment: .leading)
                    .padding(.top, 15.0)
                    
        }
    }
}

struct ToggleView_Previews: PreviewProvider {
    static var previews: some View {
        ToggleView("Settings", "gear", "open setings", "commandTrue", "commandFalse", false)
    }
}
