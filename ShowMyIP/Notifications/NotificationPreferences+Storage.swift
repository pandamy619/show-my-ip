import Foundation

extension NotificationPreferences {
    enum Key {
        static let isEnabled = "notifications.isEnabled"
        static let notifiesCountryChange = "notifications.countryChange"
        static let notifiesAddressChange = "notifications.addressChange"
        static let notifiesHomeCountry = "notifications.homeCountry"
        static let notifiesConnectionLoss = "notifications.connectionLoss"
        static let homeCountryCode = "notifications.homeCountryCode"
    }

    static func load(from defaults: UserDefaults) -> NotificationPreferences {
        let fallback = NotificationPreferences()
        func flag(_ key: String, _ defaultValue: Bool) -> Bool {
            defaults.object(forKey: key) as? Bool ?? defaultValue
        }
        return NotificationPreferences(
            isEnabled: flag(Key.isEnabled, fallback.isEnabled),
            notifiesCountryChange: flag(Key.notifiesCountryChange, fallback.notifiesCountryChange),
            notifiesAddressChange: flag(Key.notifiesAddressChange, fallback.notifiesAddressChange),
            notifiesHomeCountry: flag(Key.notifiesHomeCountry, fallback.notifiesHomeCountry),
            notifiesConnectionLoss: flag(Key.notifiesConnectionLoss, fallback.notifiesConnectionLoss),
            homeCountry: defaults.string(forKey: Key.homeCountryCode).flatMap(CountryCode.init)
        )
    }
}
