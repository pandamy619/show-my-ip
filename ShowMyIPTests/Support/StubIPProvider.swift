@testable import ShowMyIP

struct StubIPProvider: IPProvider {
    let handler: @Sendable () async throws(IPProviderError) -> IPInfo

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        try await handler()
    }
}
