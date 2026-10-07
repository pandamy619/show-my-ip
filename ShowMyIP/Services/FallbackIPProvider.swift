struct FallbackIPProvider: IPProvider {
    private let primary: any IPProvider
    private let fallbacks: [any IPProvider]

    init(primary: any IPProvider, fallbacks: [any IPProvider]) {
        self.primary = primary
        self.fallbacks = fallbacks
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        var lastError: IPProviderError
        do {
            return try await primary.fetchIPInfo()
        } catch {
            AppLogger.ipLookup.warning("Primary provider failed: \(String(describing: error), privacy: .public)")
            lastError = error
        }
        for provider in fallbacks {
            do {
                return try await provider.fetchIPInfo()
            } catch {
                AppLogger.ipLookup.warning("Fallback provider failed: \(String(describing: error), privacy: .public)")
                lastError = error
            }
        }
        throw lastError
    }
}
