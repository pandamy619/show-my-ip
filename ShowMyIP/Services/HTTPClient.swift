import Foundation

struct HTTPResponse: Sendable {
    let statusCode: Int
    let body: Data
}

enum HTTPClientError: Error, Equatable {
    case responseTooLarge
}

protocol HTTPClient: Sendable {
    func get(_ url: URL, maximumSize: Int) async throws -> HTTPResponse
}
