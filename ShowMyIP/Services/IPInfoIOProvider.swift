struct IPInfoIOProvider: IPProvider, IPDetailsProvider {
    static let maximumResponseSize = 4096
    private static let baseAddress = "https://ipinfo.io"

    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        try await fetch(from: "\(Self.baseAddress)/json")
    }

    func fetchDetails(for address: IPAddress) async throws(IPProviderError) -> IPInfo {
        try await fetch(from: "\(Self.baseAddress)/\(address.value)/json")
    }

    private func fetch(from address: String) async throws(IPProviderError) -> IPInfo {
        let data = try await client.fetchBody(from: address, maximumSize: Self.maximumResponseSize)
        do {
            return try IPInfoIOParser.parse(data)
        } catch {
            throw .invalidResponse
        }
    }
}
