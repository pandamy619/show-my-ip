import Foundation

struct URLSessionHTTPClient: HTTPClient {
    enum ClientError: Error, Equatable {
        case insecureURL
        case nonHTTPResponse
    }

    private let session: URLSession

    init(timeout: TimeInterval = 10, configuration: URLSessionConfiguration = .ephemeral) {
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        session = URLSession(configuration: configuration)
    }

    func get(_ url: URL, maximumSize: Int) async throws -> HTTPResponse {
        guard url.scheme == "https" else {
            throw ClientError.insecureURL
        }
        let (bytes, response) = try await session.bytes(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.nonHTTPResponse
        }
        guard httpResponse.expectedContentLength <= Int64(maximumSize) else {
            throw HTTPClientError.responseTooLarge
        }
        var body = Data()
        for try await byte in bytes {
            guard body.count < maximumSize else {
                throw HTTPClientError.responseTooLarge
            }
            body.append(byte)
        }
        return HTTPResponse(statusCode: httpResponse.statusCode, body: body)
    }
}
