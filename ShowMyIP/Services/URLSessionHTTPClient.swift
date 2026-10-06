import Foundation

struct URLSessionHTTPClient: HTTPClient {
    enum ClientError: Error, Equatable {
        case insecureURL
        case nonHTTPResponse
    }

    private let session: URLSession

    init(timeout: TimeInterval = 10) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        session = URLSession(configuration: configuration)
    }

    func get(_ url: URL) async throws -> HTTPResponse {
        guard url.scheme == "https" else {
            throw ClientError.insecureURL
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.nonHTTPResponse
        }
        return HTTPResponse(statusCode: httpResponse.statusCode, body: data)
    }
}
