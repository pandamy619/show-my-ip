import Darwin

struct IPAddress: Equatable, Sendable {
    enum Version: Sendable {
        case v4
        case v6
    }

    let value: String
    let version: Version

    init?(_ rawValue: String) {
        guard !rawValue.contains("\0") else {
            return nil
        }
        if Self.isValid(rawValue, family: AF_INET) {
            version = .v4
        } else if Self.isValid(rawValue, family: AF_INET6) {
            version = .v6
        } else {
            return nil
        }
        value = rawValue
    }

    private static func isValid(_ string: String, family: Int32) -> Bool {
        var address = in6_addr()
        return string.withCString { inet_pton(family, $0, &address) } == 1
    }
}
