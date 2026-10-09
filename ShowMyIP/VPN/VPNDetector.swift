enum VPNDetector {
    private static let tunnelPrefixes = ["utun", "ipsec", "ppp", "tun", "tap", "wg"]
    private static let linkLocalPrefixes = ["169.254.", "fe80:"]

    static func detect(_ interfaces: [InterfaceAddress]) -> VPNStatus {
        let tunnels = interfaces.filter { isTunnel($0.interfaceName) && isRoutable($0.address) }
        return VPNStatus(interfaceName: tunnels.map(\.interfaceName).min())
    }

    private static func isTunnel(_ name: String) -> Bool {
        tunnelPrefixes.contains { name.hasPrefix($0) }
    }

    private static func isRoutable(_ address: String) -> Bool {
        let lowercased = address.lowercased()
        return IPAddress(lowercased) != nil && !linkLocalPrefixes.contains { lowercased.hasPrefix($0) }
    }
}
