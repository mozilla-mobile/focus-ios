import Foundation

@propertyWrapper
struct UserDefault<Value> {
    private let key: String
    private let defaultValue: Value
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            // Read value from UserDefaults
            return UserDefaults.standard.value(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Set value to UserDefaults
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
