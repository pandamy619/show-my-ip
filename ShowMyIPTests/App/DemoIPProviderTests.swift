import Testing

@testable import ShowMyIP

struct DemoIPProviderTests {
    @Test func alternatesBetweenTwoCountries() async throws {
        let provider = DemoIPProvider()
        let first = try await provider.fetchIPInfo()
        let second = try await provider.fetchIPInfo()
        let third = try await provider.fetchIPInfo()
        #expect(first.country == CountryCode("NL"))
        #expect(second.country == CountryCode("DE"))
        #expect(third == first)
    }

    @Test func usesDocumentationAddressesOnly() async throws {
        let provider = DemoIPProvider()
        let infos = [try await provider.fetchIPInfo(), try await provider.fetchIPInfo()]
        let addresses = infos.flatMap(\.addresses).map(\.value)
        let documentationPrefixes = ["192.0.2.", "198.51.100.", "203.0.113.", "2001:db8:"]
        #expect(addresses.allSatisfy { address in documentationPrefixes.contains { address.hasPrefix($0) } })
    }

    @Test func providesCityAndProvider() async throws {
        let info = try await DemoIPProvider().fetchIPInfo()
        #expect(info.city != nil)
        #expect(info.organization != nil)
    }

    @Test func localAddressIsPrivate() throws {
        let local = try #require(DemoMode.localAddresses.first)
        #expect(local.interfaceName == "en0")
        #expect(local.address.value.hasPrefix("192.168."))
    }
}
