//
//  DebugPropertyTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/01.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest
@testable import DebugProperty

fileprivate struct Key {
    static let key = "integer"
}

fileprivate class DebugUtil: DebugUtilBase {
    
    @DebugProperty(key: Key.key)
    var intValue: Int = 1
}

class DebugPropertyTests: XCTestCase {
    
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
        UserDefaults.standard.set(2, forKey: Key.key)
        debugUtil = DebugUtil()
        XCTAssertEqual(debugUtil.intValue, 2)
        
        UserDefaults.standard.set(3, forKey: Key.key)
        XCTAssertEqual(debugUtil.intValue, 2)
        
        debugUtil.applicationDidResume()
        XCTAssertEqual(debugUtil.intValue, 3)
    }
    
    func testDebugUtil2() {
        debugUtil = DebugUtil()
        
        XCTAssertEqual(debugUtil.intValue, 1)
    }
}
