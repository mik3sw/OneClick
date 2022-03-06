//
//  AppDelegate.swift
//  Ambar
//
//  Created by Anagh Sharma on 12/11/19.
//  Copyright © 2019 Anagh Sharma. All rights reserved.
//

import Cocoa
import SwiftUI

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}



@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    var statusBar: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = MenuView()
        popover.contentViewController = MainViewController()
        popover.contentSize = NSSize(width: 360, height: 800)
//        popover?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        popover.contentViewController?.view = NSHostingView(rootView: contentView)
        statusBar = StatusBarController.init(popover)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

