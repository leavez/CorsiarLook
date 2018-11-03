//
//  ParserTest.swift
//  CorsairLookTests
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import XCTest
@testable import CorsairLook

class ParserTest: XCTestCase {

    let output = """
Unknown suboption `0'
Dev=0, CorsairLink Device Found: H100i Pro!

Vendor: Corsair
Product: H100i Pro
Firmware: 1.0.4.0
Temperature 0: 30.01 C
Fan 0:    Mode 0x00
    Current/Max Speed 0/0 RPM
Fan 1:    Mode 0x00
    Current/Max Speed 0/0 RPM
Pump:    Mode 0x02 (AsetekProPumpPerformance)
    Current/Max Speed 2820/0 RPM
"""

    func test_parseStatus() {
        let s = Parser.parseStatus(output)
        XCTAssertEqual(s.vender, "Corsair")
        XCTAssertEqual(s.product, "H100i Pro")
        XCTAssertEqual(s.firmware, "1.0.4.0")
        XCTAssertEqual(s.temperatures, ["30.01 C"])
        XCTAssertEqual(s.fanSpeed, ["Speed 0/0 RPM", "Speed 0/0 RPM"])
        XCTAssertEqual(s.pump.mode, "AsetekProPumpPerformance")
        XCTAssertEqual(s.pump.speed, "Speed 2820/0 RPM")

    }



}
