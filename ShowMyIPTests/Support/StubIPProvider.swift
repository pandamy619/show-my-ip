@testable import ShowMyIP

struct StubIPProvider: IPProvider {
    let handler: @Sendable () throws(IPProviderError) -> IPInfo

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        try handler()
    }
}
