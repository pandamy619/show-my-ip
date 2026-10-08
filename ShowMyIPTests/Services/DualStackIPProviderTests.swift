import Testing

@testable import ShowMyIP

struct DualStackIPProviderTests {
    private static func failing(_ error: IPProviderError) -> StubIPProvider {
        StubIPProvider { () throws(IPProviderError) -> IPInfo in throw error }
    }

    @Test func addsIPv6AsSecondaryAddress() async throws {
        let ipv4Info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let ipv6Info = try IPInfo.fixture(address: "2a01:4f8:c0c:1::1", country: "NL")
        let provider = DualStackIPProvider(ipv4: StubIPProvider { ipv4Info }, ipv6: StubIPProvider { ipv6Info })
        let info = try await provider.fetchIPInfo()
        #expect(info.address == ipv4Info.address)
        #expect(info.country == ipv4Info.country)
        #expect(info.secondaryAddress == ipv6Info.address)
    }

    @Test func ipv6FailureKeepsIPv4() async throws {
        let ipv4Info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let provider = DualStackIPProvider(ipv4: StubIPProvider { ipv4Info }, ipv6: Self.failing(.network))
        #expect(try await provider.fetchIPInfo() == ipv4Info)
    }

    @Test func ipv4FailureFallsBackToIPv6() async throws {
        let ipv6Info = try IPInfo.fixture(address: "2a01:4f8:c0c:1::1", country: "DE")
        let provider = DualStackIPProvider(ipv4: Self.failing(.network), ipv6: StubIPProvider { ipv6Info })
        #expect(try await provider.fetchIPInfo() == ipv6Info)
    }

    @Test func bothFailingThrowsIPv4Error() async {
        let provider = DualStackIPProvider(ipv4: Self.failing(.unexpectedStatus(503)), ipv6: Self.failing(.network))
        await #expect(throws: IPProviderError.unexpectedStatus(503)) {
            try await provider.fetchIPInfo()
        }
    }

    @Test func skipsIPv6WhenUnavailable() async throws {
        let ipv4Info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let ipv6 = StubIPProvider { () throws(IPProviderError) -> IPInfo in
            Issue.record("IPv6 must not be requested")
            throw .network
        }
        let provider = DualStackIPProvider(ipv4: StubIPProvider { ipv4Info }, ipv6: ipv6, isIPv6Available: { false })
        #expect(try await provider.fetchIPInfo() == ipv4Info)
    }

    @Test func ignoresNonIPv6SecondaryResult() async throws {
        let ipv4Info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let provider = DualStackIPProvider(ipv4: StubIPProvider { ipv4Info }, ipv6: StubIPProvider { ipv4Info })
        #expect(try await provider.fetchIPInfo().secondaryAddress == nil)
    }

    @Test func ignoresIPv6WhenPrimaryIsAlreadyIPv6() async throws {
        let ipv6Info = try IPInfo.fixture(address: "2a01:4f8:c0c:1::1", country: "DE")
        let provider = DualStackIPProvider(ipv4: StubIPProvider { ipv6Info }, ipv6: StubIPProvider { ipv6Info })
        #expect(try await provider.fetchIPInfo() == ipv6Info)
    }
}
