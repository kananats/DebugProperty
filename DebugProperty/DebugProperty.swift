import Foundation

public protocol Debuggable: Equatable {
    associatedtype DebugValue: Equatable
        
    init(debugValue: DebugValue)
    
    var debugValue: DebugValue { get }
}

extension Bool: Debuggable {
    public var debugValue: Bool {
        self
    }
    
    public init(debugValue: Bool) {
        self.init(debugValue)
    }
}

extension Int: Debuggable {
    public var debugValue: Int {
        self
    }
    
    public init(debugValue: Int) {
        self.init(debugValue)
    }
}

extension Double: Debuggable {
    public var debugValue: Double {
        self
    }
    
    public init(debugValue: Double) {
        self.init(debugValue)
    }
}

extension String: Debuggable {
    public var debugValue: String {
        self
    }
    
    public init(debugValue: String) {
        self.init(debugValue)
    }
}

extension Debuggable where Self: RawRepresentable {
    public var debugValue: RawValue {
        return rawValue
    }
    
    public init(debugValue: RawValue) {
        guard Self.init(rawValue: debugValue) != nil else {
            fatalError("Unexpected rawValue: \(debugValue)")
        }
        
        self.init(rawValue: debugValue)!
    }
}

fileprivate extension UserDefaults {
    func debugValue<Value: Debuggable>(forKey key: String) -> Value? {
        if let debugValue = value(forKey: key) as? Value.DebugValue {
            return Value.init(debugValue: debugValue)
        }
        return nil
    }
    
    func setDebugValue<Value: Debuggable>(_ value: Value, forKey key: String) {
        let debugValue = value.debugValue
        set(debugValue, forKey: key)
    }
}

fileprivate class KeyValueHolder<Value: Debuggable> {
    private let key: String
    var value: Value
    
    init(wrappedValue: Value?, key: String) {
        self.key = key
        if let wrappedValue: Value = UserDefaults.standard.debugValue(forKey: key) {
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
        if let value: Value = UserDefaults.standard.debugValue(forKey: key), self.value != value {
            self.value = value
        }
    }
    
    final func writeValue() {
        if let value: Value = UserDefaults.standard.debugValue(forKey: key), self.value != value {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}

fileprivate protocol Executable {
    func executeOnLaunch()
    
    func executeOnResume()
}

extension Executable {
    func executeOnLaunch() {
    }
    
    func executeOnResume() {
    }
}

@propertyWrapper
public struct DebugProperty<Value: Debuggable>: Executable {
    private let holder: KeyValueHolder<Value>

    init(wrappedValue: Value? = nil, key: String) {
        holder = KeyValueHolder(wrappedValue: wrappedValue, key: key)
    }

    public var wrappedValue: Value {
        get {
            holder.value
        }
        set {
            holder.value = newValue
        }
    }
    
    func executeOnResume() {
        holder.readValue()
    }
}

@propertyWrapper
public struct ResetProperty: Executable {
    private let holder: KeyValueHolder<Key>

    init(wrappedValue: Key? = nil, key: String) {
        holder = KeyValueHolder(wrappedValue: wrappedValue, key: key)
    }
    
    public var wrappedValue: Key {
        get {
            return holder.value
        }
        set {
            holder.value = newValue
        }
    }
    
    func executeOnLaunch() {
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
    
    public enum Key: Int, Debuggable {
        case never
        case once
        case always
    }
}

open class DebugUtilBase {
    private(set) var closures: [() -> Void] = []
        
    init() {
        let mirror = Mirror(reflecting: self)
        for (_, value) in mirror.children {
            if let value = value as? Executable {
                value.executeOnLaunch()
                closures.append(value.executeOnResume)
            }
        }
    }
    
    func applicationDidResume() {
        for closure in closures {
            closure()
        }
    }
}


