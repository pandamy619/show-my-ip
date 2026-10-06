import Testing

@testable import ShowMyIP

struct LocalAddressFilterTests {
    private func displayable(_ entries: [(String, String)]) -> [String] {
        let interfaces = entries.map { InterfaceAddress(interfaceName: $0.0, address: $0.1) }
        return LocalAddressFilter.displayable(interfaces).map { "\($0.interfaceName) \($0.address.value)" }
    }

    @Test func keepsPhysicalInterfaceAddresses() {
        #expect(displayable([("en0", "192.168.1.5")]) == ["en0 192.168.1.5"])
    }

    @Test func dropsLoopbackAndVirtualInterfaces() {
        let result = displayable([("lo0", "127.0.0.1"), ("utun4", "10.8.0.2"), ("bridge0", "10.0.0.1")])
        #expect(result.isEmpty)
    }

    @Test func dropsLinkLocalAddresses() {
        #expect(displayable([("en0", "169.254.10.20"), ("en0", "fe80::1%en0")]).isEmpty)
    }

    @Test func keepsGlobalIPv6() {
        #expect(displayable([("en0", "2a01:4f8:c0c:1::1")]) == ["en0 2a01:4f8:c0c:1::1"])
    }

    @Test func dropsInvalidAddresses() {
        #expect(displayable([("en0", "not-an-ip")]).isEmpty)
    }

    @Test func ordersIPv4BeforeIPv6() {
        let result = displayable([("en0", "2a01:4f8:c0c:1::1"), ("en1", "10.0.0.7")])
        #expect(result == ["en1 10.0.0.7", "en0 2a01:4f8:c0c:1::1"])
    }
}
