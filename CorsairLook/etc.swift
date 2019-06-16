//
//  etc.swift
//  CorsairLook
//
//  Created by leave on 2019/6/16.
//  Copyright © 2019 me.leavez. All rights reserved.
//

import Foundation
import AppKit
import RxCocoa
import RxSwift

class SystemSleepState {
    
    static let shared = SystemSleepState()
    
    var isSleeped = false
    
    init() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { (_) in
            self.isSleeped = false
        }
        center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { (_) in
            self.isSleeped = true
        }
    }
}
