import Foundation
import Testing

@testable import ShowMyIP

struct PrivacyMaskingTests {
    private let locale = Locale(identifier: "en_US")

    @Test func fullLabelMasksAddress() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        #expect(MenuBarLabel.make(for: .loaded(info), isHidden: true) == .text("🇳🇱 •••"))
    }

    @Test func fullLabelWithoutCountryMasksAddress() throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        #expect(MenuBarLabel.make(for: .loaded(info), isHidden: true) == .text("🌐 •••"))
    }

    @Test func compactLabelIsUnchanged() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let label = MenuBarLabel.make(
            for: .loaded(info),
            isCompact: true,
            compactStyle: .flagAndCountryCode,
            isHidden: true
        )
        #expect(label == .text("🇳🇱 NL"))
    }

    @Test func menuMasksAddressesButKeepsThemCopyable() throws {
        let address = try #require(IPAddress("185.23.45.67"))
        let local = LocalAddress(interfaceName: "en0", address: try #require(IPAddress("192.168.1.5")))
        let info = IPInfo(address: address, country: CountryCode("NL"), city: "Amsterdam", organization: "AS1 Example")
        let items = MenuInfoBuilder.items(for: .loaded(info), localAddresses: [local], locale: locale, isHidden: true)
        #expect(
            items == [
                MenuInfoItem(title: "🇳🇱 Netherlands"),
                MenuInfoItem(title: "Public IPv4: •••", copyValue: "185.23.45.67"),
                MenuInfoItem(title: "Local IP (en0): •••", copyValue: "192.168.1.5"),
            ]
        )
    }

    @Test func addressChangeNotificationHidesAddresses() throws {
        let from = try #require(IPAddress("1.1.1.1"))
        let to = try #require(IPAddress("2.2.2.2"))
        let content = NotificationContentBuilder.content(
            for: .addressChanged(from: from, to: to),
            locale: locale,
            isHidden: true
        )
        let expected = NotificationContent(title: "IP address changed", body: "Your public IP address has changed.")
        #expect(content == expected)
    }
}
