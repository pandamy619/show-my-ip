import Foundation
import Testing

@testable import ShowMyIP

struct DNSLeakTests {
    private let locale = Locale(identifier: "en_US")

    private static func info(country: String, resolverCountry: String?) throws -> IPInfo {
        let resolver = DNSResolver(
            address: try #require(IPAddress("203.0.113.53")),
            country: resolverCountry.flatMap(CountryCode.init),
            organization: nil
        )
        return try IPInfo.fixture(address: "185.23.45.67", country: country).withDNSResolver(resolver)
    }

    @Test func resolverInAnotherCountryIsALeak() throws {
        #expect(try Self.info(country: "NL", resolverCountry: "RU").dnsLeakCountry == CountryCode("RU"))
    }

    @Test(arguments: ["NL", nil] as [String?])
    func sameOrUnknownResolverCountryIsNotALeak(resolverCountry: String?) throws {
        #expect(try Self.info(country: "NL", resolverCountry: resolverCountry).dnsLeakCountry == nil)
    }

    @Test func menuShowsResolverCountry() throws {
        let info = try Self.info(country: "NL", resolverCountry: "NL")
        let items = MenuInfoBuilder.items(for: .loaded(info), localAddresses: [], locale: locale)
        #expect(items.contains(MenuInfoItem(title: "DNS: 🇳🇱 Netherlands")))
    }

    @Test(arguments: [false, true])
    func menuWarnsAboutDNSLeak(isHidden: Bool) throws {
        let info = try Self.info(country: "NL", resolverCountry: "RU")
        let items = MenuInfoBuilder.items(for: .loaded(info), localAddresses: [], locale: locale, isHidden: isHidden)
        #expect(items.contains(MenuInfoItem(title: "⚠️ DNS leak: 🇷🇺 Russia")))
    }

    @Test func dnsLeakNotifiesWhenItStarts() throws {
        var decider = NotificationDecider()
        let preferences = NotificationPreferences(isEnabled: true)
        let netherlands = try #require(CountryCode("NL"))
        let russia = try #require(CountryCode("RU"))
        _ = decider.process(.loaded(try Self.info(country: "NL", resolverCountry: "NL")), preferences: preferences)
        let leaking = AppState.Status.loaded(try Self.info(country: "NL", resolverCountry: "RU"))
        let expected = IPNotification.dnsLeak(ipCountry: netherlands, dnsCountry: russia)
        #expect(decider.process(leaking, preferences: preferences) == expected)
        #expect(decider.process(leaking, preferences: preferences) == nil)
    }

    @Test func dnsLeakIsSilentWhenDisabled() throws {
        var decider = NotificationDecider()
        var preferences = NotificationPreferences(isEnabled: true)
        preferences.notifiesDNSLeak = false
        let leaking = AppState.Status.loaded(try Self.info(country: "NL", resolverCountry: "RU"))
        #expect(decider.process(leaking, preferences: preferences) == nil)
    }

    @Test func dnsLeakNotificationNamesBothCountries() throws {
        let notification = IPNotification.dnsLeak(
            ipCountry: try #require(CountryCode("NL")),
            dnsCountry: try #require(CountryCode("RU"))
        )
        let expected = NotificationContent(
            title: "Possible DNS leak",
            body: "DNS queries go through 🇷🇺 Russia, traffic through 🇳🇱 Netherlands.",
            playsSound: true
        )
        #expect(NotificationContentBuilder.content(for: notification, locale: locale) == expected)
    }
}
