//
//  StringNoDefaultTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest
@testable import DebugProperty

fileprivate class DebugUtil: DebugUtilBase {
    
    @DebugProperty(key: key)
    var value: String
}

class StringNoDefaultTests: BaseTests {
    
    private var debugUtil: DebugUtil!

    override func tearDown() {
        debugUtil = nil
    }
    
    func testString() {
        UserDefaults.standard.set("2", forKey: key)
        debugUtil = DebugUtil()
        XCTAssertEqual(debugUtil.value, "2")
        
        UserDefaults.standard.set("3", forKey: key)
        XCTAssertEqual(debugUtil.value, "2")
        
        debugUtil.applicationDidResume()
        XCTAssertEqual(debugUtil.value, "3")
    }
}
