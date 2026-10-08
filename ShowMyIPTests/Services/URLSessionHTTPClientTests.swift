import Foundation
import Testing

@testable import ShowMyIP

struct URLSessionHTTPClientTests {
    private static let maximumSize = 4096

    private static func makeClient() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSessionHTTPClient(configuration: configuration)
    }

    @Test(arguments: ["http://www.cloudflare.com/cdn-cgi/trace", "ftp://example.com/file", "file:///etc/hosts"])
    func nonHTTPSURLIsRejected(address: String) async throws {
        let url = try #require(URL(string: address))
        await #expect(throws: URLSessionHTTPClient.ClientError.insecureURL) {
            try await URLSessionHTTPClient().get(url, maximumSize: Self.maximumSize)
        }
    }

    @Test(arguments: [0, 100, 4096])
    func returnsBodyWithinLimit(bodySize: Int) async throws {
        let url = try #require(StubURLProtocol.url(bodySize: bodySize))
        let response = try await Self.makeClient().get(url, maximumSize: Self.maximumSize)
        #expect(response.statusCode == 200)
        #expect(response.body.count == bodySize)
    }

    @Test func stopsReadingOversizedBody() async throws {
        let url = try #require(StubURLProtocol.url(bodySize: 1_000_000))
        await #expect(throws: HTTPClientError.responseTooLarge) {
            try await Self.makeClient().get(url, maximumSize: Self.maximumSize)
        }
    }

    @Test func passesThroughStatusCode() async throws {
        let url = try #require(StubURLProtocol.url(bodySize: 10, statusCode: 503))
        let response = try await Self.makeClient().get(url, maximumSize: Self.maximumSize)
        #expect(response.statusCode == 503)
    }
}
