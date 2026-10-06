struct InterfaceAddress: Equatable, Sendable {
    let interfaceName: String
    let address: String
}

enum LocalAddressFilter {
    private static let physicalInterfacePrefix = "en"
    private static let linkLocalPrefixes = ["169.254.", "fe80:"]

    static func displayable(_ interfaces: [InterfaceAddress]) -> [LocalAddress] {
        interfaces
            .filter { $0.interfaceName.hasPrefix(physicalInterfacePrefix) && !isLinkLocal($0.address) }
            .compactMap { interface in
                IPAddress(interface.address).map { LocalAddress(interfaceName: interface.interfaceName, address: $0) }
            }
            .sorted { $0.address.version == .v4 && $1.address.version == .v6 }
    }

    private static func isLinkLocal(_ address: String) -> Bool {
        let lowercased = address.lowercased()
        return linkLocalPrefixes.contains { lowercased.hasPrefix($0) }
    }
}
