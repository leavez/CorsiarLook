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
    let pumpModeSubmenu = Variable<DeviceService.Status.PumpMode?>(nil)
    

    
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
        
        s.bumpMode.asObservable().map {"Pump Mode: " + $0.rawValue}.bind(to: pumpMode).disposed(by: bag)
        
        
        raw.skip(1).map {$0.temperatures?.first ?? ""}.bind(to: statusBarTitle).disposed(by: bag)
        
        
        // setup intial state
        DeviceService.shared.setLEDToStaticWhite()
        
        
        // functions
        // auto adjust pump mode
        let tempModeSiganl = s.temperature.asObservable().map({ (value) -> DeviceService.Status.PumpMode  in
            if value < 30 {
                return .quiet
            } else if value < 35 {
                return .balanced
            } else {
                return .performance
            }
        }).distinctUntilChanged()
        
        let settingSignal = automaticallySetPumpMode.asObservable()
        Observable.combineLatest(settingSignal, tempModeSiganl).filter { (auto, mode) -> Bool in
            auto
            }.map { (_, mode) in mode }
            .subscribe(onNext: { (value) in
                DeviceService.shared.set(pumpMode: value)
            }).disposed(by: bag)

        Observable.combineLatest(s.bumpMode.asObservable(),
                                 automaticallySetPumpMode.asObservable())
            .map { (mode, auto) -> DeviceService.Status.PumpMode? in
                if auto {
                    return nil
                } else {
                    return mode
                }
        }.bind(to: pumpModeSubmenu).disposed(by: bag)
    }
    
    
    func didSelect(pumpMode: DeviceService.Status.PumpMode) {
        automaticallySetPumpMode.value = false
        DeviceService.shared.set(pumpMode: pumpMode)
    }
    func didSelectPumpModeAuto() {
        automaticallySetPumpMode.value = true
    }
    
    
    let setting = Setting()
    private let automaticallySetPumpMode = Variable(true)
    
    class Setting {
        let updateDuration = Variable(2.0)
        let automaticallyChangePumpMode = Variable(true)
        
        init() {
            updateDuration.asObservable().flatMapLatest({ d -> Observable<Int> in
                if d == 0 {
                    return Observable<Int>.empty()
                } else {
                    return Observable<Int>.interval(d, scheduler: MainScheduler.asyncInstance)
                }
            }).subscribe(onNext: { _ in
                DeviceService.shared.fetchStatus()
            }).disposed(by: bag)
        }
        
        private let bag = DisposeBag()
        
    }

}


