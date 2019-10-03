//
//  DoubleTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest
@testable import DebugProperty

fileprivate class DebugUtil: DebugUtilBase {
    
    @DebugProperty(key: key)
    var value: Double = 1
}

class DoubleTests: BaseTests {
    
    private var debugUtil: DebugUtil!

    override func tearDown() {
        debugUtil = nil
    }
    
    func testDoubleWithDefault() {
        UserDefaults.standard.set(2, forKey: key)
        debugUtil = DebugUtil()
        XCTAssertEqual(debugUtil.value, 2)
        
        UserDefaults.standard.set(3, forKey: key)
        XCTAssertEqual(debugUtil.value, 2)
        
        debugUtil.applicationDidResume()
        XCTAssertEqual(debugUtil.value, 3)
    }
    
    func testDouble() {
        debugUtil = DebugUtil()
        
        XCTAssertEqual(debugUtil.value, 1.0)
    }
}
