enum MenuBarAddress: String, CaseIterable, Identifiable, Sendable {
    case ipv4
    case ipv6

    var id: Self { self }

    var title: String {
        switch self {
        case .ipv4:
            "IPv4"
        case .ipv6:
            "IPv6"
        }
    }

    var version: IPAddress.Version {
        switch self {
        case .ipv4:
            .v4
        case .ipv6:
            .v6
        }
    }
}
