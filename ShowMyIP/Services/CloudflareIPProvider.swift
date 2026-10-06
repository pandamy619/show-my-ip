import Foundation

struct CloudflareIPProvider: IPProvider {
    static let maximumResponseSize = 4096
    private static let traceAddress = "https://www.cloudflare.com/cdn-cgi/trace"

    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        let data = try await client.fetchBody(from: Self.traceAddress, maximumSize: Self.maximumResponseSize)
        guard let body = String(data: data, encoding: .utf8) else {
            throw .invalidEncoding
        }
        do {
            return try CloudflareTraceParser.parse(body)
        } catch {
            throw .invalidResponse
        }
    }
}
