import Foundation
import Testing

@testable import ShowMyIP

struct MenuInfoBuilderTests {
    private let locale = Locale(identifier: "en_US")

    private func items(for status: AppState.Status, localAddresses: [LocalAddress] = []) -> [MenuInfoItem] {
        MenuInfoBuilder.items(for: status, localAddresses: localAddresses, locale: locale)
    }

    @Test func loadedShowsAllDetails() throws {
        let address = try #require(IPAddress("185.23.45.67"))
        let info = IPInfo(address: address, country: CountryCode("NL"), city: "Amsterdam", organization: "AS1 Example")
        #expect(
            items(for: .loaded(info)) == [
                MenuInfoItem(title: "🇳🇱 Netherlands"),
                MenuInfoItem(title: "Public IPv4: 185.23.45.67", copyValue: "185.23.45.67"),
                MenuInfoItem(title: "City: Amsterdam"),
                MenuInfoItem(title: "Provider: AS1 Example"),
            ]
        )
    }

    @Test func loadedWithoutDetailsShowsOnlyAddress() throws {
        let info = try IPInfo.fixture(address: "2a01:4f8:c0c:1::1")
        let expected = MenuInfoItem(title: "Public IPv6: 2a01:4f8:c0c:1::1", copyValue: "2a01:4f8:c0c:1::1")
        #expect(items(for: .loaded(info)) == [expected])
    }

    @Test func dualStackShowsBothPublicAddresses() throws {
        let ipv4 = try #require(IPAddress("185.23.45.67"))
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let info = IPInfo(address: ipv4, country: nil, secondaryAddress: ipv6)
        #expect(
            items(for: .loaded(info)) == [
                MenuInfoItem(title: "Public IPv4: 185.23.45.67", copyValue: "185.23.45.67"),
                MenuInfoItem(title: "Public IPv6: 2a01:4f8:c0c:1::1", copyValue: "2a01:4f8:c0c:1::1"),
            ]
        )
    }

    @Test func statusMessagesForNonLoadedStates() {
        #expect(items(for: .loading) == [MenuInfoItem(title: "Loading…")])
        #expect(items(for: .offline) == [MenuInfoItem(title: "No network connection")])
        #expect(items(for: .failed(.network)) == [MenuInfoItem(title: "Could not determine public IP")])
    }

    @Test func localAddressesAreAppendedAndCopyable() throws {
        let address = try #require(IPAddress("192.168.1.5"))
        let result = items(for: .offline, localAddresses: [LocalAddress(interfaceName: "en0", address: address)])
        #expect(result.last == MenuInfoItem(title: "Local IP (en0): 192.168.1.5", copyValue: "192.168.1.5"))
    }
}
