import Foundation

struct PrivacyPreferences: Equatable, Sendable {
    enum Key {
        static let allowsHiding = "privacy.allowsHiding"
        static let hidesOnLaunch = "privacy.hidesOnLaunch"
    }

    private static let separators: Set<Character> = [".", ":"]
    private static let maskCharacter: Character = "*"

    var allowsHiding = false
    var hidesOnLaunch = false

    static func masked(_ address: String) -> String {
        String(address.map { separators.contains($0) ? $0 : maskCharacter })
    }

    static func load(from defaults: UserDefaults) -> PrivacyPreferences {
        PrivacyPreferences(
            allowsHiding: defaults.bool(forKey: Key.allowsHiding),
            hidesOnLaunch: defaults.bool(forKey: Key.hidesOnLaunch)
        )
    }
}
