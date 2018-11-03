//
//  AppDelegate.swift
//  CorsairLook
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @IBOutlet weak var menu: NSMenu!

    @IBOutlet weak var tempertureLine: NSMenuItem!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // set up the status view in status bar
        statusItem.button?.title = "Corsair"
        statusItem.menu = menu
        
        // temperture
        setUpTempertureLine()
        
        let view = NSView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.layer?.backgroundColor = NSColor.red.cgColor
        
//        tempertureLine.view = view
        
        
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusItem.button?.title = "123"
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func didTapQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
    
    
    
    // MARK:- temperture
    
    func setUpTempertureLine() {
//        let t = DeviceService.shared.temperture.getStatue()
//        tempertureLine.title = "t\(t) C"
    }
    
    

    
}

