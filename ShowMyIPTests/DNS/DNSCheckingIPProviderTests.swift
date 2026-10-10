import Testing

@testable import ShowMyIP

struct DNSCheckingIPProviderTests {
    private struct StubLookup: DNSResolverLookup {
        let address: IPAddress?

        func resolverAddress() async -> IPAddress? {
            address
        }
    }

    private struct StubResolverDetails: IPDetailsProvider {
        let calls = CallCounter()
        let country: String?

        func fetchDetails(for address: IPAddress) async throws(IPProviderError) -> IPInfo {
            await calls.increment()
            guard let country else {
                throw .network
            }
            return IPInfo(address: address, country: CountryCode(country), organization: "AS13335 Cloudflare")
        }
    }

    private static func makeProvider(
        base: IPInfo,
        resolver: String? = "203.0.113.53",
        details: StubResolverDetails = StubResolverDetails(country: "NL"),
        isEnabled: Bool = true
    ) -> DNSCheckingIPProvider {
        DNSCheckingIPProvider(
            base: StubIPProvider { base },
            lookup: StubLookup(address: resolver.flatMap(IPAddress.init)),
            details: details,
            isEnabled: { isEnabled }
        )
    }

    @Test func disabledCheckLeavesInfoUntouched() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let details = StubResolverDetails(country: "NL")
        #expect(try await Self.makeProvider(base: base, details: details, isEnabled: false).fetchIPInfo() == base)
        #expect(await details.calls.count < 1)
    }

    @Test func addsResolverWithCountryAndProvider() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let info = try await Self.makeProvider(base: base).fetchIPInfo()
        let resolver = try #require(info.dnsResolver)
        #expect(resolver.address.value == "203.0.113.53")
        #expect(resolver.country == CountryCode("NL"))
        #expect(resolver.organization == "AS13335 Cloudflare")
        #expect(info.address == base.address)
    }

    @Test func failedLookupLeavesInfoUntouched() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        #expect(try await Self.makeProvider(base: base, resolver: nil).fetchIPInfo() == base)
    }

    @Test func failedDetailsKeepResolverAddress() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let info = try await Self.makeProvider(base: base, details: StubResolverDetails(country: nil)).fetchIPInfo()
        #expect(info.dnsResolver?.address.value == "203.0.113.53")
        #expect(info.dnsResolver?.country == nil)
    }

    @Test func sameResolverReusesDetails() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let details = StubResolverDetails(country: "NL")
        let provider = Self.makeProvider(base: base, details: details)
        _ = try await provider.fetchIPInfo()
        _ = try await provider.fetchIPInfo()
        #expect(await details.calls.count == 1)
    }
}
