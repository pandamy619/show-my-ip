struct DetailsEnrichingIPProvider: IPProvider {
    private actor Cache {
        private var details: IPInfo?

        func details(for address: IPAddress) -> IPInfo? {
            details?.address == address ? details : nil
        }

        func store(_ details: IPInfo) {
            self.details = details
        }
    }

    private let base: any IPProvider
    private let detailsProvider: any IPDetailsProvider
    private let isEnabled: @Sendable () -> Bool
    private let cache = Cache()

    init(base: any IPProvider, details: any IPDetailsProvider, isEnabled: @escaping @Sendable () -> Bool) {
        self.base = base
        self.detailsProvider = details
        self.isEnabled = isEnabled
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        let info = try await base.fetchIPInfo()
        guard isEnabled(), let details = await cachedDetails(for: info.address) else {
            return info
        }
        return IPInfo(
            address: info.address,
            country: info.country ?? details.country,
            city: info.city ?? details.city,
            organization: info.organization ?? details.organization,
            coordinate: info.coordinate ?? details.coordinate,
            secondaryAddress: info.secondaryAddress,
            secondaryCountry: info.secondaryCountry
        )
    }

    private func cachedDetails(for address: IPAddress) async -> IPInfo? {
        if let cached = await cache.details(for: address) {
            return cached
        }
        do {
            let fetched = try await detailsProvider.fetchDetails(for: address)
            guard fetched.address == address else {
                return nil
            }
            await cache.store(fetched)
            return fetched
        } catch {
            AppLogger.ipLookup.warning("Details lookup failed: \(String(describing: error), privacy: .public)")
            return nil
        }
    }
}
