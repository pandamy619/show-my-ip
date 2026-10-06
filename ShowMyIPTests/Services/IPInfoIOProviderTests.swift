import Foundation
import Testing

@testable import ShowMyIP

struct IPInfoIOProviderTests {
    private static let sampleJSON = Data(#"{"ip": "185.23.45.67", "country": "NL", "city": "Amsterdam"}"#.utf8)

    private func makeProvider(statusCode: Int = 200, body: Data = sampleJSON) -> IPInfoIOProvider {
        IPInfoIOProvider(client: StubHTTPClient { _ in HTTPResponse(statusCode: statusCode, body: body) })
    }

    @Test func returnsParsedInfo() async throws {
        let info = try await makeProvider().fetchIPInfo()
        #expect(info.address.value == "185.23.45.67")
        #expect(info.city == "Amsterdam")
    }

    @Test func requestsIPInfoOverHTTPS() async throws {
        let provider = IPInfoIOProvider(
            client: StubHTTPClient { url in
                #expect(url.absoluteString == "https://ipinfo.io/json")
                return HTTPResponse(statusCode: 200, body: Self.sampleJSON)
            }
        )
        _ = try await provider.fetchIPInfo()
    }

    @Test func rateLimitStatusThrows() async {
        await #expect(throws: IPProviderError.unexpectedStatus(429)) {
            try await makeProvider(statusCode: 429).fetchIPInfo()
        }
    }

    @Test func oversizedResponseThrows() async {
        let oversized = Data(repeating: 0x61, count: IPInfoIOProvider.maximumResponseSize + 1)
        await #expect(throws: IPProviderError.responseTooLarge) {
            try await makeProvider(body: oversized).fetchIPInfo()
        }
    }

    @Test func unparsableResponseThrows() async {
        await #expect(throws: IPProviderError.invalidResponse) {
            try await makeProvider(body: Data("<html>blocked</html>".utf8)).fetchIPInfo()
        }
    }
}
