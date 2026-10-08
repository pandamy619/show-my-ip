enum IPProviderError: Error, Equatable {
    case invalidRequest
    case network
    case unexpectedStatus(Int)
    case responseTooLarge
    case invalidEncoding
    case invalidResponse
}

protocol IPProvider: Sendable {
    func fetchIPInfo() async throws(IPProviderError) -> IPInfo
}

protocol IPDetailsProvider: Sendable {
    func fetchDetails(for address: IPAddress) async throws(IPProviderError) -> IPInfo
}
