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




func sudocomando(arg: String) -> Void {
    let task = Process()
    task.launchPath = "/usr/sbin/pmset"
    task.arguments = ["-a", "lowpowermode", "1"]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
}


