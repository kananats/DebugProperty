//
//  EnumNoDefaultTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest
@testable import DebugProperty

fileprivate enum Enum: Int, Debuggable {
    case zero
    case one
    case two
}

fileprivate class DebugUtil: DebugUtilBase {
    
    @DebugProperty(key: key)
    var enumValue: Enum = .zero
}

class EnumNoDefaultTests: BaseTests {
    
    private var debugUtil: DebugUtil!

    override func tearDown() {
        debugUtil = nil
    }

    func testEnum() {
        UserDefaults.standard.set(Enum.one.rawValue, forKey: key)
        
        debugUtil = DebugUtil()
        XCTAssertEqual(debugUtil.enumValue, .one)
        
        UserDefaults.standard.set(2, forKey: key)
        XCTAssertEqual(debugUtil.enumValue, .one)
        
        debugUtil.applicationDidResume()
        XCTAssertEqual(debugUtil.enumValue, .two)
    }
}
