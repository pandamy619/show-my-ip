import Foundation

struct HTTPResponse: Sendable {
    let statusCode: Int
    let body: Data
}

protocol HTTPClient: Sendable {
    func get(_ url: URL) async throws -> HTTPResponse
}
