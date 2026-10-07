import Foundation
import Testing

@testable import ShowMyIP

struct NotificationPreferencesStorageTests {
    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func emptyStorageGivesDefaults() throws {
        #expect(NotificationPreferences.load(from: try makeDefaults()) == NotificationPreferences())
    }

    @Test func readsStoredValues() throws {
        let defaults = try makeDefaults()
        defaults.set(true, forKey: NotificationPreferences.Key.isEnabled)
        defaults.set(false, forKey: NotificationPreferences.Key.notifiesCountryChange)
        defaults.set(true, forKey: NotificationPreferences.Key.notifiesAddressChange)
        defaults.set(false, forKey: NotificationPreferences.Key.notifiesHomeCountry)
        defaults.set(true, forKey: NotificationPreferences.Key.notifiesConnectionLoss)
        defaults.set("RU", forKey: NotificationPreferences.Key.homeCountryCode)

        let expected = NotificationPreferences(
            isEnabled: true,
            notifiesCountryChange: false,
            notifiesAddressChange: true,
            notifiesHomeCountry: false,
            notifiesConnectionLoss: true,
            homeCountry: CountryCode("RU")
        )
        #expect(NotificationPreferences.load(from: defaults) == expected)
    }

    @Test func invalidHomeCountryIsIgnored() throws {
        let defaults = try makeDefaults()
        defaults.set("<script>", forKey: NotificationPreferences.Key.homeCountryCode)
        #expect(NotificationPreferences.load(from: defaults).homeCountry == nil)
    }
}
