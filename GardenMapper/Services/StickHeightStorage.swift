import Foundation

protocol StickHeightStoring {
    var stickHeight: Int { get set }
}

final class StickHeightStorage: StickHeightStoring {
    static let defaultHeight = 120
    static let minHeight = 20
    static let maxHeight = 300

    private let defaults: UserDefaults
    private let key = "stickHeightCm"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var stickHeight: Int {
        get {
            let stored = defaults.integer(forKey: key)
            if stored == 0 { return Self.defaultHeight }
            return Self.clamp(stored)
        }
        set {
            defaults.set(Self.clamp(newValue), forKey: key)
        }
    }

    static func clamp(_ value: Int) -> Int {
        max(minHeight, min(maxHeight, value))
    }
}
