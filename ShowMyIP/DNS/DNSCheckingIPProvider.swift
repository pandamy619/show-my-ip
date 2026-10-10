struct DNSCheckingIPProvider: IPProvider {
    private actor Cache {
        private var resolver: DNSResolver?

        func resolver(for address: IPAddress) -> DNSResolver? {
            resolver?.address == address ? resolver : nil
        }

        func store(_ resolver: DNSResolver) {
            self.resolver = resolver
        }
    }

    private let base: any IPProvider
    private let lookup: any DNSResolverLookup
    private let detailsProvider: any IPDetailsProvider
    private let isEnabled: @Sendable () -> Bool
    private let cache = Cache()

    init(
        base: any IPProvider,
        lookup: any DNSResolverLookup,
        details: any IPDetailsProvider,
        isEnabled: @escaping @Sendable () -> Bool
    ) {
        self.base = base
        self.lookup = lookup
        self.detailsProvider = details
        self.isEnabled = isEnabled
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        let info = try await base.fetchIPInfo()
        guard isEnabled(), let address = await lookup.resolverAddress() else {
            return info
        }
        return info.withDNSResolver(await resolver(for: address))
    }

    private func resolver(for address: IPAddress) async -> DNSResolver {
        if let cached = await cache.resolver(for: address) {
            return cached
        }
        do {
            let details = try await detailsProvider.fetchDetails(for: address)
            let resolver = DNSResolver(
                address: address,
                country: details.address == address ? details.country : nil,
                organization: details.address == address ? details.organization : nil
            )
            await cache.store(resolver)
            return resolver
        } catch {
            AppLogger.ipLookup.warning("DNS resolver details failed: \(String(describing: error), privacy: .public)")
            return DNSResolver(address: address, country: nil, organization: nil)
        }
    }
}
