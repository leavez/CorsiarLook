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

    @IBOutlet weak var nameLIne: NSMenuItem!
    @IBOutlet weak var tempertureLine: NSMenuItem!
    @IBOutlet weak var fanLine: NSMenuItem!
    @IBOutlet weak var pumpMode: NSMenuItem!
    @IBOutlet weak var pumpLine: NSMenuItem!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // set up the status view in status bar
        statusItem.button?.title = "Corsair"
        statusItem.menu = menu
        
        
        let s = DeviceService.shared.getStatus()
        tempertureLine.title = "Temperature \(s.temperatures?.first ?? "")"
        
//        let view = NSView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        view.layer?.backgroundColor = NSColor.red.cgColor
//        let label = NSTextView(frame: .zero)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.string = "\(s)"
////        tempertureLine.view = label
//
//        tLabel.stringValue = "\(s.temperatures?.first)"
        
        func update(includeOutter:Bool = true) {
            let s = DeviceService.shared.getStatus()
            if includeOutter {
                self.statusItem.button?.title = s.temperatures?.first ?? "NO TEMP"
            }
            self.nameLIne.title = s.vender + " " + s.product
            self.tempertureLine.title = "Temperature: " + (s.temperatures?.first ?? "")
            self.fanLine.title = "Fan: " + (s.fanSpeed.map { $0.joined(separator: ", ") } ?? "")
            self.pumpLine.title = "Pump Mode: " + s.pump.mode
            self.pumpMode.title = "Pump Speed: " + s.pump.speed
        }
        
        update(includeOutter: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                update()
            }
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func didTapQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
    
    
    

    
    
}

