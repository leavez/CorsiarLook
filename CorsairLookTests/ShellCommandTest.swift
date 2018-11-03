//
//  ShellCommandTest.swift
//  CorsairLookTests
//
//  Created by Leave Gao on 2018/11/3.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import XCTest
@testable import CorsairLook

class ShellCommandTest: XCTestCase {


    func test_haveLibFile() {
        XCTAssertNotNil(Communicator().executeLibPath)
    }

    func test_canRunShellCommand() {
        let output = Communicator.shell("pwd")
        XCTAssertTrue(output != nil && output!.count > 0)
    }
    
    func test_corsairCommand() {
        let output = Communicator().command("")
        XCTAssertTrue(output.count > 0)
    }


}
