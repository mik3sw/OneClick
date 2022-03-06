//
//  functions.swift
//  OneClick
//
//  Created by Michele Marcucci on 15/12/21.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import Foundation

func comando(arg: String) -> Void {
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", arg]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
}

func comandoOut(arg: String) -> String {
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", arg]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)
    task.waitUntilExit()
    return output!
}


func whichBG() -> String {
    var bg = ""
    if (comandoOut(arg: darkModeStatus)).contains("true") {
        bg = getDarkBG()
    } else {
        bg = getLightBG()
    }
    
    return bg
}


func getDarkBG() -> String {
    return darkBG
}

func getLightBG() -> String {
    return lightBG
}

extension String {
    func runAppleScript(isShellCMD:Bool = false) -> (Bool, Any) {
        var finalCommand = self
        if isShellCMD {
            finalCommand = "do shell script \"\(self)\""
        }
        print("command:\(finalCommand)")
        var error: NSDictionary?
        if let scroptObject = NSAppleScript(source: finalCommand) {
            let descriptor = scroptObject.executeAndReturnError(&error)
            if let outputString = descriptor.stringValue {
                print(outputString)
                return (true, outputString)
            } else if error != nil {
                print("error:\(String(describing: error!))")
                return (false, "failed")
            }
        }
        return (true, "")
    }
}
