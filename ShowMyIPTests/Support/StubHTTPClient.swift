import Foundation

@testable import ShowMyIP

struct StubHTTPClient: HTTPClient {
    let handler: @Sendable (URL) throws -> HTTPResponse

    func get(_ url: URL, maximumSize: Int) async throws -> HTTPResponse {
        try handler(url)
    }
}
