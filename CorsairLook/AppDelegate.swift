//
//  AppDelegate.swift
//  CorsairLook
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @IBOutlet weak var menu: NSMenu!

    @IBOutlet weak var nameLIne: NSMenuItem!
    @IBOutlet weak var tempertureLine: NSMenuItem!
    @IBOutlet weak var fanLine: NSMenuItem!
    @IBOutlet weak var pumpSpeed: NSMenuItem!
    @IBOutlet weak var pumpModeSelectionLine: NSMenuItem!
    
    
    let viewModel = ViewModel()

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // set up the status view in status bar
        statusItem.menu = menu
        bind(viewModel: viewModel)
    }

    
    
    
    
    // MARK:- binding
    
    let bag = DisposeBag()
    
    func bind(viewModel: ViewModel) {
        
        func bind<T>(keyPath:KeyPath<ViewModel, Variable<T>>, tokeyPath: ReferenceWritableKeyPath<AppDelegate, T>) {
            viewModel[keyPath:keyPath].asObservable().bind {
                [weak self] (s) in
                self?[keyPath: tokeyPath] = s
            }.disposed(by: bag)
        }
        
        bind(keyPath: \ViewModel.statusBarTitle, tokeyPath: \AppDelegate.statusItem.button!.title)
        bind(keyPath: \ViewModel.name, tokeyPath: \AppDelegate.nameLIne.title)
        bind(keyPath: \ViewModel.temperature, tokeyPath: \AppDelegate.tempertureLine.title)
        bind(keyPath: \ViewModel.fan, tokeyPath: \AppDelegate.fanLine.title)
        bind(keyPath: \ViewModel.pumpSpeed, tokeyPath: \AppDelegate.pumpSpeed.title)
        bind(keyPath: \ViewModel.pumpMode, tokeyPath: \AppDelegate.pumpModeSelectionLine.title)

        viewModel.pumpModeSubmenu.asObservable().bind {[unowned self] (mode) in
            var index = 0
            if let mode = mode {
                switch mode {
                case .quiet: index = 1
                case .balanced: index = 2
                case .performance: index = 3
                }
            }
            self.pumpModeSelectionLine.submenu?.items.forEach{ $0.state = .off}
            self.pumpModeSelectionLine.submenu?.items[index].state = .on
        }.disposed(by: bag)
        
    }
    

    

    @IBAction func didTapQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
    @IBAction func didTapPumpModeAuto(_ sender: Any) {
        viewModel.didSelectPumpModeAuto()
    }
    @IBAction func didTapPumpModeQuiet(_ sender: Any) {
        viewModel.didSelect(pumpMode: .quiet)
    }
    @IBAction func didTapPumpModeBalanced(_ sender: Any) {
        viewModel.didSelect(pumpMode: .balanced)
    }
    @IBAction func didTapPumpModePerformance(_ sender: Any) {
        viewModel.didSelect(pumpMode: .performance)
    }
    
    @IBAction func didTapLEDModeWhite(_ sender: Any) {
        DeviceService.shared.setLEDToStaticWhite()
    }
    @IBAction func didTapLEDModeOrange(_ sender: Any) {
        DeviceService.shared.setLEDToStaticColor(hex: "ff2200")
    }
    @IBAction func didTapLEDModeRainbow(_ sender: Any) {
        DeviceService.shared.setLEDToBreathRainbow()
    }
    
    
}

