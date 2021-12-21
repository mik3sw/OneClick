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

let showHiddenFiles = "defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder"
let hideHiddenFiles = "defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder"

let batterySavingOn = "osascript -e 'do shell script \"pmset -a lowpowermode 1\" with administrator privileges'"
let batterySavingOff = "osascript -e 'do shell script \"pmset -a lowpowermode 0\" with administrator privileges'"

let caffeinateOn = "caffeinate"
let caffeinateOff = "killall caffeinate"

let darkModeOn = "osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to true'"
let darkModeOff = "osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to false'"

let setAutohideDockOn = "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to true'"
let setAutohideDockOff = "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to false'"


let emptyTrash = "osascript -e 'tell application \"Finder\" to empty trash'"
let purgeMemory = "osascript -e 'do shell script \"purge\" with administrator privileges'"
let screenshot = "screencapture -T 3 -t png -P Desktop/screenshot.png"
