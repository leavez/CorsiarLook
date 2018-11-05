//
//  ViewModelTest.swift
//  CorsairLookTests
//
//  Created by Leave Gao on 2018/11/5.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxCocoa
@testable import CorsairLook

class ViewModelSpecs: QuickSpec {
 
    override func spec() {
        describe("the view model") {
            
            let vm = ViewModel()
            context("when initialized") {
                
                it("simple display model should equal deviceStatus") {
                    expect(vm.temperature.value).notTo(beEmpty())
                    expect(vm.pumpSpeed.value).notTo(beEmpty())
                    expect(vm.fan.value).notTo(beEmpty())
                    expect(vm.name.value).notTo(beEmpty())
                }
                
            }
            
            context("when change auto pump mode") {
                
                it("pump submodel should be nil when set to auto") {
                    vm.didSelectPumpModeAuto()
                    expect(vm.pumpModeSubmenu.value).to(beNil())
                }
                it("pump submodel should equal deviceStatus when set to mannuly") {
                    vm.didSelect(pumpMode: .quiet)
                    expect(vm.pumpModeSubmenu.value).to(equal(DeviceService.shared.status.bumpMode.value))
                }
            }
            
            // for setting features
            
            context("when change show temperature on statusbar") {
                it("show text when off") {
                    vm.setting.didToggleShowTemperatureOnStatusBar()
                    expect(vm.statusBarTitle.value) == "Corsair"
                }
                it("show temp when on") {
                    vm.setting.didToggleShowTemperatureOnStatusBar()
                    expect(vm.statusBarTitle.value) == DeviceService.shared.status.rawStatus.value?.temperatures?.first
                }
            }
            
            context("when change the update interval") {
                
                it("should update after 2 seconds on default") {
                    // mock is very trival here, we just use some other property to indicate
                    var calledCount = 0
                    _ = DeviceService.shared.status.rawStatus.asObservable().subscribe(onNext: { i in
                        calledCount += 1
                    })
                    expect(calledCount).toEventually(equal(2), timeout: 4.1)
                }
                
                it("should update for every 0.5 seconds when change the interval") {
                    vm.setting.didSelectUpdateDuration(0.5)
                    var calledCount = 0
                    _ = DeviceService.shared.status.rawStatus.asObservable().subscribe(onNext: { i in
                        calledCount += 1
                    })
                    expect(calledCount).toEventually(equal(2), timeout: 1.1)
                }
            }
            
        }
    }
}
