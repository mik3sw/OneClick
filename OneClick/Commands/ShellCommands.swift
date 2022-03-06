//
//  ShellCommand.swift
//  OneClick
//
//  Created by Michele Marcucci on 19/12/21.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import Foundation

let hideDesktop = "defaults write com.apple.finder CreateDesktop false ; killall Finder"
let showDesktop = "defaults write com.apple.finder CreateDesktop true ; killall Finder"
let statusDesktop = "defaults read com.apple.finder CreateDesktop"

let showHiddenFiles = "defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder"
let hideHiddenFiles = "defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder"
let statusFiles = "defaults read com.apple.finder AppleShowAllFiles"

let batterySavingOn = "osascript -e 'do shell script \"pmset -a lowpowermode 1\" with administrator privileges'"
let batterySavingOff = "osascript -e 'do shell script \"pmset -a lowpowermode 0\" with administrator privileges'"
let statusBatterySaving = "pmset -g"

let caffeinateOn = "caffeinate"
let caffeinateOff = "killall caffeinate"

let darkModeOn = "osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to true'"
let darkModeOff = "osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to false'"
let darkModeStatus = "osascript -e 'tell application \"System Events\" to tell appearance preferences to get dark mode'"

let setAutohideDockOn = "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to true'"
let setAutohideDockOff = "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to false'"
let statusAutohideDock = "osascript -e 'tell application \"System Events\" to get the autohide of the dock preferences'"


let setAutohideMenuBarOn = "osascript -e 'tell application \"System Events\" to set the autohide menu bar of the dock preferences to true'"
let setAutohideMenuBarOff = "osascript -e 'tell application \"System Events\" to set the autohide menu bar of the dock preferences to false'"
let statusAutohideMenuBar = "osascript -e 'tell application \"System Events\" to get the autohide menu bar of the dock preferences'"


let emptyTrash = "osascript -e 'tell application \"Finder\" to empty trash'"
let purgeMemory = "osascript -e 'do shell script \"purge\" with administrator privileges'"
let screenshot = "screencapture -T 3 -t png -P Desktop/screenshot.png"




//@State var statusDock = (comandoOut(arg: statusAutohideDock)).contains("true")
//@State var statusDesk = (comandoOut(arg: statusDesktop)).contains("false")
//@State var statusFile = (comandoOut(arg: statusFiles)).contains("1")
//@State var statusPower = (comandoOut(arg: statusBatterySaving)).contains("lowpowermode         1")
//@State var statusDark = (comandoOut(arg: darkModeStatus)).contains("true")
