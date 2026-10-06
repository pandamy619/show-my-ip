struct IPInfoIOProvider: IPProvider {
    static let maximumResponseSize = 4096
    private static let address = "https://ipinfo.io/json"

    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        let data = try await client.fetchBody(from: Self.address, maximumSize: Self.maximumResponseSize)
        do {
            return try IPInfoIOParser.parse(data)
        } catch {
            throw .invalidResponse
        }
    }
}
