import Testing

@testable import ShowMyIP

struct FallbackIPProviderTests {
    @Test func usesPrimaryWhenItSucceeds() async throws {
        let expected = try IPInfo.fixture(address: "1.1.1.1", country: "NL")
        let provider = FallbackIPProvider(
            primary: StubIPProvider { expected },
            fallbacks: [
                StubIPProvider { () throws(IPProviderError) -> IPInfo in
                    Issue.record("Fallback must not be called")
                    throw .network
                }
            ]
        )
        #expect(try await provider.fetchIPInfo() == expected)
    }

    @Test func usesFirstSuccessfulFallback() async throws {
        let expected = try IPInfo.fixture(address: "8.8.8.8", country: "DE")
        let provider = FallbackIPProvider(
            primary: StubIPProvider { () throws(IPProviderError) -> IPInfo in throw .network },
            fallbacks: [
                StubIPProvider { () throws(IPProviderError) -> IPInfo in throw .unexpectedStatus(429) },
                StubIPProvider { expected },
            ]
        )
        #expect(try await provider.fetchIPInfo() == expected)
    }

    @Test func throwsLastErrorWhenAllFail() async {
        let provider = FallbackIPProvider(
            primary: StubIPProvider { () throws(IPProviderError) -> IPInfo in throw .network },
            fallbacks: [StubIPProvider { () throws(IPProviderError) -> IPInfo in throw .invalidResponse }]
        )
        await #expect(throws: IPProviderError.invalidResponse) {
            try await provider.fetchIPInfo()
        }
    }
}
