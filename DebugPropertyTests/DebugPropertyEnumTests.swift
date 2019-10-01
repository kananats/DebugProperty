//
//  DebugPropertyEnumTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/01.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest
@testable import DebugProperty

fileprivate struct Key {
    static let key = "enum"
}

fileprivate enum DebugEnum: Int {
    case one
    case two
    case three
}

fileprivate class DebugUtil: DebugUtilBase {
    
    @DebugProperty(key: Key.key)
    var enumValue: DebugEnum = .one
}

class DebugPropertyEnumTests: XCTestCase {
    
    private var debugUtil: DebugUtil!
    
    override func setUp() {
        deleteAllUserDefaults()
    }

    override func tearDown() {
        debugUtil = nil
    }

    private func deleteAllUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }

    func testDebugUtil1() {
        UserDefaults.standard.set(DebugEnum.two.rawValue, forKey: Key.key)
        debugUtil = DebugUtil()
        XCTAssertEqual(debugUtil.enumValue, .two)
        
        UserDefaults.standard.set(3, forKey: Key.key)
        XCTAssertEqual(debugUtil.enumValue, .two)
        
        debugUtil.applicationDidResume()
        XCTAssertEqual(debugUtil.enumValue, .three)
    }
    
    func testDebugUtil2() {
        debugUtil = DebugUtil()
        
        XCTAssertEqual(debugUtil.enumValue, .one)
    }
}
