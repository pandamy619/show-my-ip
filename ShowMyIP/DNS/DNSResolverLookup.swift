import Darwin

protocol DNSResolverLookup: Sendable {
    func resolverAddress() async -> IPAddress?
}

struct SystemDNSResolverLookup: DNSResolverLookup {
    private static let probeHost = "whoami.akamai.net"

    func resolverAddress() async -> IPAddress? {
        await Task.detached { Self.lookUpResolver() }.value
    }

    private static func lookUpResolver() -> IPAddress? {
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        var results: UnsafeMutablePointer<addrinfo>?
        guard getaddrinfo(probeHost, nil, &hints, &results) == 0, let first = results else {
            return nil
        }
        defer { freeaddrinfo(results) }
        let hostLength = Int(NI_MAXHOST)
        var host = [CChar](repeating: 0, count: hostLength)
        let status = getnameinfo(
            first.pointee.ai_addr,
            first.pointee.ai_addrlen,
            &host,
            socklen_t(hostLength),
            nil,
            0,
            NI_NUMERICHOST
        )
        guard status == 0 else {
            return nil
        }
        let bytes = host.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        return String(bytes: bytes, encoding: .utf8).flatMap(IPAddress.init)
    }
}
