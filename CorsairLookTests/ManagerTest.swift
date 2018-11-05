//
//  ManagerTest.swift
//  CorsairLookTests
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import XCTest
@testable import CorsairLook

class ManagerTest: XCTestCase {

    func test_getStatus() {
        let s = DeviceService.shared.fetchStatus()
        XCTAssertTrue(s.product.count > 0)
        XCTAssertTrue(s.pump.mode.count > 0)
        XCTAssertNotNil(s.temperatures?.first)
    }

}
