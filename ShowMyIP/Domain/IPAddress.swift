import Darwin

struct IPAddress: Equatable, Sendable {
    enum Version: Sendable {
        case v4
        case v6
    }

    private static let allowedCharacters = Set("0123456789abcdefABCDEF.:")
    private static let maximumLength = 45
    private static let globalUnicastMask: UInt8 = 0xE0
    private static let globalUnicastPrefix: UInt8 = 0x20

    let value: String
    let version: Version

    init?(_ rawValue: String) {
        guard rawValue.count <= Self.maximumLength, rawValue.allSatisfy(Self.allowedCharacters.contains) else {
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

    var isGlobalIPv6: Bool {
        guard version == .v6 else {
            return false
        }
        var address = in6_addr()
        guard value.withCString({ inet_pton(AF_INET6, $0, &address) }) == 1 else {
            return false
        }
        return address.__u6_addr.__u6_addr8.0 & Self.globalUnicastMask == Self.globalUnicastPrefix
    }

    private static func isValid(_ string: String, family: Int32) -> Bool {
        var address = in6_addr()
        return string.withCString { inet_pton(family, $0, &address) } == 1
    }
}
