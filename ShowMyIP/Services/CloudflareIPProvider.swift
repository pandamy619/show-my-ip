import Foundation

struct CloudflareIPProvider: IPProvider {
    static let maximumResponseSize = 4096
    private static let traceAddress = "https://www.cloudflare.com/cdn-cgi/trace"
    private static let successStatusCode = 200

    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        guard let url = URL(string: Self.traceAddress) else {
            throw .invalidRequest
        }
        let response: HTTPResponse
        do {
            response = try await client.get(url)
        } catch {
            throw .network
        }
        guard response.statusCode == Self.successStatusCode else {
            throw .unexpectedStatus(response.statusCode)
        }
        guard response.body.count <= Self.maximumResponseSize else {
            throw .responseTooLarge
        }
        guard let body = String(data: response.body, encoding: .utf8) else {
            throw .invalidEncoding
        }
        do {
            return try CloudflareTraceParser.parse(body)
        } catch {
            throw .invalidResponse
        }
    }
}
