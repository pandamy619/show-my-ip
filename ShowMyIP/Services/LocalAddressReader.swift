import Darwin
import Foundation

enum LocalAddressReader {
    static func read() -> [LocalAddress] {
        LocalAddressFilter.displayable(readInterfaceAddresses())
    }

    static func hasGlobalIPv6() -> Bool {
        readInterfaceAddresses().contains { IPAddress($0.address)?.isGlobalIPv6 == true }
    }

    private static func readInterfaceAddresses() -> [InterfaceAddress] {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else {
            return []
        }
        defer { freeifaddrs(head) }
        return sequence(first: first) { $0.pointee.ifa_next }.compactMap { interfaceAddress(from: $0.pointee) }
    }

    private static func interfaceAddress(from interface: ifaddrs) -> InterfaceAddress? {
        guard interface.ifa_flags & UInt32(IFF_UP) != 0, let socketAddress = interface.ifa_addr else {
            return nil
        }
        let family = Int32(socketAddress.pointee.sa_family)
        guard family == AF_INET || family == AF_INET6 else {
            return nil
        }
        let hostLength = Int(NI_MAXHOST)
        var host = [CChar](repeating: 0, count: hostLength)
        let status = getnameinfo(
            socketAddress,
            socklen_t(socketAddress.pointee.sa_len),
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
        guard let address = String(bytes: bytes, encoding: .utf8) else {
            return nil
        }
        return InterfaceAddress(interfaceName: String(cString: interface.ifa_name), address: address)
    }
}
