import Foundation

struct PrivacyPreferences: Equatable, Sendable {
    enum Key {
        static let allowsHiding = "privacy.allowsHiding"
        static let hidesOnLaunch = "privacy.hidesOnLaunch"
    }

    static let mask = "•••"

    var allowsHiding = false
    var hidesOnLaunch = false

    static func load(from defaults: UserDefaults) -> PrivacyPreferences {
        PrivacyPreferences(
            allowsHiding: defaults.bool(forKey: Key.allowsHiding),
            hidesOnLaunch: defaults.bool(forKey: Key.hidesOnLaunch)
        )
    }
}
