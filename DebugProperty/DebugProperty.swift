import Foundation

private func makeKeyValueHolder<Value>(wrappedValue: Value?, key: String) -> KeyValueHolder<Value> {
    return KeyValueHolder(wrappedValue: wrappedValue, key: key)
}

private func makeEnumKeyValueHolder<Value: RawRepresentable>(wrappedValue: Value?, key: String) -> KeyValueHolder<Value> {
    return EnumKeyValueHolder(wrappedValue: wrappedValue, key: key)
}

fileprivate final class EnumKeyValueHolder<Value: RawRepresentable & Equatable>: KeyValueHolder<Value> {
    private var rawValue: Value.RawValue

    override var value: Value {
        get {
            return Value(rawValue: rawValue)!
        }
        set {
            rawValue = newValue.rawValue
            super.value = newValue
        }
    }
    
    override init(wrappedValue: Value?, key: String) {
        if let wrappedValue = UserDefaults.standard.value(forKey: key) as? Value.RawValue {
            rawValue = wrappedValue
        } else if let wrappedValue = wrappedValue?.rawValue {
            rawValue = wrappedValue
        } else {
            fatalError("Please ensure that value exists for key \(key)")
        }
        
        super.init(wrappedValue: wrappedValue, key: key)
    }
}

fileprivate class KeyValueHolder<Value: Equatable> {
    private let key: String
    var value: Value
    
    init(wrappedValue: Value?, key: String) {
        self.key = key
        if let wrappedValue = UserDefaults.standard.value(forKey: key) as? Value {
            value = wrappedValue
        } else if let wrappedValue = wrappedValue {
            value = wrappedValue
        } else {
            fatalError("Please ensure that value exists for key \(key)")
        }
        readValue()
        writeValue()
    }

    final func readValue() {
        if let value = UserDefaults.standard.value(forKey: key) as? Value, self.value != value {
            self.value = value
        }
    }
    
    final func writeValue() {
        if UserDefaults.standard.value(forKey: key) as? Value != value {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}

fileprivate protocol DebugPropertyProtocol {
    func execute()
}

@propertyWrapper
struct DebugProperty<Value: Equatable>: DebugPropertyProtocol {
    private let holder: KeyValueHolder<Value>

    init(wrappedValue: Value? = nil, key: String) {
        holder = makeKeyValueHolder(wrappedValue: wrappedValue, key: key)
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
        holder.readValue()
    }
}

fileprivate protocol ResetPropertyProtocol: DebugPropertyProtocol {
}

@propertyWrapper
struct ResetProperty: ResetPropertyProtocol {
    private let holder: KeyValueHolder<Key>

    init(wrappedValue: Key? = nil, key: String) {
        holder = makeKeyValueHolder(wrappedValue: wrappedValue, key: key)
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


