import Testing

@testable import ShowMyIP

struct DetailsEnrichingIPProviderTests {
    private struct StubDetailsProvider: IPDetailsProvider {
        let calls = CallCounter()
        let handler: @Sendable (IPAddress) throws(IPProviderError) -> IPInfo

        func fetchDetails(for address: IPAddress) async throws(IPProviderError) -> IPInfo {
            await calls.increment()
            return try handler(address)
        }
    }

    private static func details(for address: IPAddress, country: String = "DE") -> IPInfo {
        IPInfo(address: address, country: CountryCode(country), city: "Amsterdam", organization: "AS1 Example")
    }

    private static func makeProvider(
        base: IPInfo,
        details: StubDetailsProvider,
        isEnabled: Bool = true
    ) -> DetailsEnrichingIPProvider {
        DetailsEnrichingIPProvider(base: StubIPProvider { base }, details: details, isEnabled: { isEnabled })
    }

    @Test func disabledSkipsDetailsRequest() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let details = StubDetailsProvider { Self.details(for: $0) }
        let info = try await Self.makeProvider(base: base, details: details, isEnabled: false).fetchIPInfo()
        #expect(info == base)
        #expect(await details.calls.count == 0)
    }

    @Test func enabledAddsCityAndProviderButKeepsCountry() async throws {
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL").withSecondaryAddress(ipv6)
        let details = StubDetailsProvider { Self.details(for: $0) }
        let info = try await Self.makeProvider(base: base, details: details).fetchIPInfo()
        #expect(info.address == base.address)
        #expect(info.secondaryAddress == ipv6)
        #expect(info.country == CountryCode("NL"))
        #expect(info.city == "Amsterdam")
        #expect(info.organization == "AS1 Example")
    }

    @Test func missingCountryIsTakenFromDetails() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67")
        let details = StubDetailsProvider { Self.details(for: $0, country: "DE") }
        #expect(try await Self.makeProvider(base: base, details: details).fetchIPInfo().country == CountryCode("DE"))
    }

    @Test func detailsFailureKeepsBaseInfo() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let details = StubDetailsProvider { _ throws(IPProviderError) -> IPInfo in throw .unexpectedStatus(429) }
        #expect(try await Self.makeProvider(base: base, details: details).fetchIPInfo() == base)
    }

    @Test func detailsForAnotherAddressAreIgnored() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let other = try #require(IPAddress("8.8.8.8"))
        let details = StubDetailsProvider { _ in Self.details(for: other) }
        #expect(try await Self.makeProvider(base: base, details: details).fetchIPInfo() == base)
    }

    @Test func sameAddressReusesCachedDetails() async throws {
        let base = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let details = StubDetailsProvider { Self.details(for: $0) }
        let provider = Self.makeProvider(base: base, details: details)
        _ = try await provider.fetchIPInfo()
        let second = try await provider.fetchIPInfo()
        #expect(second.city == "Amsterdam")
        #expect(await details.calls.count == 1)
    }

    @Test func baseFailureIsPropagated() async {
        let details = StubDetailsProvider { Self.details(for: $0) }
        let provider = DetailsEnrichingIPProvider(
            base: StubIPProvider { () throws(IPProviderError) -> IPInfo in throw .network },
            details: details,
            isEnabled: { true }
        )
        await #expect(throws: IPProviderError.network) {
            try await provider.fetchIPInfo()
        }
    }
}
