import XCTest

let key = "key"

class BaseTests: XCTestCase {
    
    final override func setUp() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
