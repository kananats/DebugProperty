//
//  BaseTests.swift
//  DebugPropertyTests
//
//  Created by Kananat Suwanviwatana on 2019/10/03.
//  Copyright © 2019 Kananat Suwanviwatana. All rights reserved.
//

import XCTest

let key = "key"

class BaseTests: XCTestCase {
    
    final override func setUp() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
