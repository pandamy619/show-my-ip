import Foundation
import Testing

@testable import ShowMyIP

struct CloudflareIPProviderTests {
    private struct ConnectionLost: Error {}

    private static let sampleTrace = Data("ip=185.23.45.67\nloc=NL\n".utf8)

    private func makeProvider(statusCode: Int = 200, body: Data = sampleTrace) -> CloudflareIPProvider {
        CloudflareIPProvider(client: StubHTTPClient { _ in HTTPResponse(statusCode: statusCode, body: body) })
    }

    @Test func returnsParsedInfo() async throws {
        let info = try await makeProvider().fetchIPInfo()
        #expect(info.address.value == "185.23.45.67")
        #expect(info.country == CountryCode("NL"))
    }

    @Test func requestsCloudflareTraceOverHTTPS() async throws {
        let provider = CloudflareIPProvider(
            client: StubHTTPClient { url in
                #expect(url.absoluteString == "https://www.cloudflare.com/cdn-cgi/trace")
                return HTTPResponse(statusCode: 200, body: Self.sampleTrace)
            }
        )
        _ = try await provider.fetchIPInfo()
    }

    @Test(arguments: [
        CloudflareIPProvider.ipv4TraceAddress,
        CloudflareIPProvider.ipv6TraceAddress,
    ])
    func requestsGivenTraceAddress(address: String) async throws {
        let provider = CloudflareIPProvider(
            client: StubHTTPClient { url in
                #expect(url.absoluteString == address)
                return HTTPResponse(statusCode: 200, body: Self.sampleTrace)
            },
            traceAddress: address
        )
        _ = try await provider.fetchIPInfo()
    }

    @Test func pinsTraceAddressesToAddressFamilies() {
        #expect(CloudflareIPProvider.ipv4TraceAddress == "https://1.1.1.1/cdn-cgi/trace")
        #expect(CloudflareIPProvider.ipv6TraceAddress == "https://[2606:4700:4700::1111]/cdn-cgi/trace")
    }

    @Test func nonSuccessStatusThrows() async {
        await #expect(throws: IPProviderError.unexpectedStatus(503)) {
            try await makeProvider(statusCode: 503).fetchIPInfo()
        }
    }

    @Test func oversizedResponseThrows() async {
        let oversized = Data(repeating: 0x61, count: CloudflareIPProvider.maximumResponseSize + 1)
        await #expect(throws: IPProviderError.responseTooLarge) {
            try await makeProvider(body: oversized).fetchIPInfo()
        }
    }

    @Test func clientSizeLimitIsReportedAsTooLarge() async {
        let provider = CloudflareIPProvider(client: StubHTTPClient { _ in throw HTTPClientError.responseTooLarge })
        await #expect(throws: IPProviderError.responseTooLarge) {
            try await provider.fetchIPInfo()
        }
    }

    @Test func nonUTF8ResponseThrows() async {
        await #expect(throws: IPProviderError.invalidEncoding) {
            try await makeProvider(body: Data([0xFF, 0xFE, 0xFD])).fetchIPInfo()
        }
    }

    @Test func unparsableResponseThrows() async {
        await #expect(throws: IPProviderError.invalidResponse) {
            try await makeProvider(body: Data("<html>blocked</html>".utf8)).fetchIPInfo()
        }
    }

    @Test func clientFailureThrowsNetworkError() async {
        let provider = CloudflareIPProvider(client: StubHTTPClient { _ in throw ConnectionLost() })
        await #expect(throws: IPProviderError.network) {
            try await provider.fetchIPInfo()
        }
    }
}
