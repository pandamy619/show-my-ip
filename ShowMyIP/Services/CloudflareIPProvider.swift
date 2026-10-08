import Foundation

struct CloudflareIPProvider: IPProvider {
    static let maximumResponseSize = 4096
    static let traceAddress = "https://www.cloudflare.com/cdn-cgi/trace"
    static let ipv4TraceAddress = "https://1.1.1.1/cdn-cgi/trace"
    static let ipv6TraceAddress = "https://[2606:4700:4700::1111]/cdn-cgi/trace"

    private let client: any HTTPClient
    private let traceAddress: String

    init(client: any HTTPClient, traceAddress: String = Self.traceAddress) {
        self.client = client
        self.traceAddress = traceAddress
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        let data = try await client.fetchBody(from: traceAddress, maximumSize: Self.maximumResponseSize)
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
