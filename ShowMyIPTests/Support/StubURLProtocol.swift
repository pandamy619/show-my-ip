import Foundation

final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    static let host = "stub.test"

    static func url(bodySize: Int, statusCode: Int = 200) -> URL? {
        URL(string: "https://\(host)/\(statusCode)/\(bodySize)")
    }

    override static func canInit(with request: URLRequest) -> Bool {
        request.url?.host == host
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard
            let url = request.url,
            url.pathComponents.count == 3,
            let statusCode = Int(url.pathComponents[1]),
            let bodySize = Int(url.pathComponents[2]),
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(repeating: 0x61, count: bodySize))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
