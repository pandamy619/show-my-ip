struct DualStackIPProvider: IPProvider {
    private let ipv4: any IPProvider
    private let ipv6: any IPProvider

    init(ipv4: any IPProvider, ipv6: any IPProvider) {
        self.ipv4 = ipv4
        self.ipv6 = ipv6
    }

    func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
        async let ipv4Result = Self.result(of: ipv4)
        async let ipv6Result = Self.result(of: ipv6)
        let (primary, secondary) = await (ipv4Result, ipv6Result)
        switch (primary, secondary) {
        case (.success(let info), .success(let ipv6Info)):
            return Self.combine(info, withIPv6From: ipv6Info)
        case (.success(let info), .failure(let error)):
            AppLogger.ipLookup.info("IPv6 lookup failed: \(String(describing: error), privacy: .public)")
            return info
        case (.failure(let error), .success(let ipv6Info)):
            AppLogger.ipLookup.warning("IPv4 lookup failed: \(String(describing: error), privacy: .public)")
            return ipv6Info
        case (.failure(let error), .failure):
            throw error
        }
    }

    private static func combine(_ info: IPInfo, withIPv6From ipv6Info: IPInfo) -> IPInfo {
        guard ipv6Info.address.version == .v6, info.address.version == .v4 else {
            return info
        }
        return info.withSecondaryAddress(ipv6Info.address)
    }

    private static func result(of provider: any IPProvider) async -> Result<IPInfo, IPProviderError> {
        do {
            return .success(try await provider.fetchIPInfo())
        } catch {
            return .failure(error)
        }
    }
}
