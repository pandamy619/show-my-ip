import Foundation
import Testing

@testable import ShowMyIP

struct URLSessionHTTPClientTests {
    @Test(arguments: ["http://www.cloudflare.com/cdn-cgi/trace", "ftp://example.com/file", "file:///etc/hosts"])
    func nonHTTPSURLIsRejected(address: String) async throws {
        let url = try #require(URL(string: address))
        await #expect(throws: URLSessionHTTPClient.ClientError.insecureURL) {
            try await URLSessionHTTPClient().get(url)
        }
    }
}
