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
