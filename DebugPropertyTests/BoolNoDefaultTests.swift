//
//  BoolNoDefaultTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest
@testable import DebugProperty

fileprivate class DebugUtil: DebugUtilBase {
    
    @DebugProperty(key: key)
    var value: Bool
}

class BoolNoDefaultTests: BaseTests {
    
    private var debugUtil: DebugUtil!

    override func tearDown() {
        debugUtil = nil
    }

    func testBool() {
        UserDefaults.standard.set(false, forKey: key)
        debugUtil = DebugUtil()
        XCTAssertEqual(debugUtil.value, false)
        
        UserDefaults.standard.set(true, forKey: key)
        XCTAssertEqual(debugUtil.value, false)
        
        debugUtil.applicationDidResume()
        XCTAssertEqual(debugUtil.value, true)
    }
}
