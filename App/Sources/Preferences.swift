import Foundation

enum Preferences {
    private static let d = UserDefaults.standard
    static var persianDigits: Bool {
        get { d.bool(forKey: "persianDigits") }
        set { d.set(newValue, forKey: "persianDigits") }
    }
    static var showLineNumbers: Bool {
        get { d.object(forKey: "showLineNumbers") as? Bool ?? true }
        set { d.set(newValue, forKey: "showLineNumbers") }
    }
    static var ignoreVariants: Bool {
        get { d.object(forKey: "ignoreVariants") as? Bool ?? true }
        set { d.set(newValue, forKey: "ignoreVariants") }
    }
}
