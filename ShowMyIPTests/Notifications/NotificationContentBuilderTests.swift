import Foundation
import Testing

@testable import ShowMyIP

struct NotificationContentBuilderTests {
    private let locale = Locale(identifier: "en_US")

    private func content(for notification: IPNotification) -> NotificationContent {
        NotificationContentBuilder.content(for: notification, locale: locale)
    }

    @Test func countryChange() {
        let result = content(for: .countryChanged(from: CountryCode("NL"), to: CountryCode("DE")))
        #expect(result == NotificationContent(title: "Country changed", body: "🇳🇱 Netherlands → 🇩🇪 Germany"))
    }

    @Test func ipv6Leak() throws {
        let notification = IPNotification.ipv6Leak(
            ipv4Country: try #require(CountryCode("NL")),
            ipv6Country: try #require(CountryCode("RU"))
        )
        let expected = NotificationContent(
            title: "Possible IPv6 leak",
            body: "IPv6 goes through 🇷🇺 Russia, IPv4 through 🇳🇱 Netherlands.",
            playsSound: true
        )
        #expect(content(for: notification) == expected)
    }

    @Test func countryChangeToUnknown() {
        let result = content(for: .countryChanged(from: CountryCode("NL"), to: nil))
        #expect(result.body == "🇳🇱 Netherlands → 🌐 Unknown")
    }

    @Test func addressChange() throws {
        let from = try #require(IPAddress("1.1.1.1"))
        let to = try #require(IPAddress("2.2.2.2"))
        let result = content(for: .addressChanged(from: from, to: to))
        #expect(result == NotificationContent(title: "IP address changed", body: "1.1.1.1 → 2.2.2.2"))
    }

    @Test func homeCountryPlaysSound() throws {
        let result = content(for: .homeCountryDetected(try #require(CountryCode("RU"))))
        let expected = NotificationContent(
            title: "VPN may be off",
            body: "You are online from 🇷🇺 Russia",
            playsSound: true
        )
        #expect(result == expected)
    }

    @Test func connectionLost() {
        let result = content(for: .connectionLost)
        #expect(result == NotificationContent(title: "Connection lost", body: "No network connection"))
    }
}
