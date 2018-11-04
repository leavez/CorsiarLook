//
//  ViewModel.swift
//  CorsairLook
//
//  Created by Leave Gao on 2018/11/5.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    let statusBarTitle = Variable("Corsair")
    
    let name = Variable("(name)")
    let temperature = Variable("(temperature)")
    let fan = Variable("(fan speed)")
    let pumpSpeed = Variable("(pump speed)")
    let pumpMode = Variable("(pump mode)")
    let pumpModeSubmenu = Variable(DeviceService.Status.PumpMode.quiet)

    private let bag = DisposeBag()
    
    init() {
        let s = DeviceService.shared.status
        let raw = s.rawStatus.asObservable().flatMap { Observable.from(optional: $0) }
        
        raw.map { $0.vender + " " + $0.product }
            .bind(to: name).disposed(by: bag)
        
        raw.map({ "Temperature: " + ($0.temperatures?.joined(separator: ", ") ?? "" ) })
            .bind(to: temperature).disposed(by: bag)
        
        raw.map { "Fan: " + ($0.fanSpeed.map { $0.joined(separator: ", ") } ?? "") }
            .bind(to: fan).disposed(by: bag)
        
        raw.map { "Pump Speed: " + $0.pump.speed }
            .bind(to: pumpSpeed).disposed(by: bag)
        
        s.bumpMode.asObservable().bind(to: pumpModeSubmenu).disposed(by: bag)
        s.bumpMode.asObservable().map {"Pump Mode: " + $0.rawValue}.bind(to: pumpMode).disposed(by: bag)
    }
    
    
    func didSelect(pumpMode: DeviceService.Status.PumpMode) {
        DeviceService.shared.set(pumpMode: pumpMode)
    }
}


