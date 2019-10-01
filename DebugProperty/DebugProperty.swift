import Foundation

fileprivate final class KeyValueHolder<Value: Equatable> {
    private let key: String
    var value: Value
    
    init(wrappedValue: Value, key: String) {
        self.key = key
        value = wrappedValue
        value = storedValue
        storedValue = value
    }

    convenience init(key: String) {
        guard let value = UserDefaults.standard.value(forKey: key) as? Value else {
            fatalError("Please ensure that value exists for key \(key)")
        }
        
        self.init(wrappedValue: value, key: key)
    }
    
    func updateValue() {
        value = storedValue
    }
    
    private var storedValue: Value {
        get {
            UserDefaults.standard.value(forKey: key) as? Value ?? self.value
        }
        set {
            if UserDefaults.standard.value(forKey: key) as? Value != newValue {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

fileprivate protocol DebugPropertyProtocol {
    func execute()
}

@propertyWrapper
struct DebugProperty<Value: Equatable>: DebugPropertyProtocol {
    private let holder: KeyValueHolder<Value>
    
    init(key: String) {
        holder = KeyValueHolder(key: key)
    }
    
    init(wrappedValue: Value, key: String) {
        holder = KeyValueHolder(wrappedValue: wrappedValue, key: key)
    }

    var wrappedValue: Value {
        get {
            holder.value
        }
        set {
            holder.value = newValue
        }
    }
    
    func execute() {
        holder.updateValue()
    }
}

fileprivate protocol ResetPropertyProtocol: DebugPropertyProtocol {
}

@propertyWrapper
struct ResetProperty: ResetPropertyProtocol {
    private let holder: KeyValueHolder<Key>
    
    init(key: String) {
        holder = KeyValueHolder(key: key)
    }
    
    init(wrappedValue: Key, key: String) {
        holder = KeyValueHolder(wrappedValue: wrappedValue, key: key)
    }
    
    var wrappedValue: Key {
        get {
            return holder.value
        }
        set {
            holder.value = newValue
        }
    }
    
    func execute() {
        switch wrappedValue {
        case .never:
            break
        case .once:
            deleteAllUserDefaults()
            holder.value = .never
        default:
            deleteAllUserDefaults()
        }
    }
    
    private func deleteAllUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }
    
    enum Key: Int {
        case never
        case once
        case always
    }
}

class DebugUtilBase {
    private(set) var closures: [() -> Void] = []
        
    init() {
        let mirror = Mirror(reflecting: self)
        for (_, value) in mirror.children {
            if let value = value as? ResetPropertyProtocol {
                value.execute()
            } else if let value = value as? DebugPropertyProtocol {
                closures.append(value.execute)
            }
        }
    }
    
    func applicationDidResume() {
        for closure in closures {
            closure()
        }
    }
}


