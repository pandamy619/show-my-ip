import Testing

@testable import ShowMyIP

struct VPNDetectorTests {
    private static func interface(_ name: String, _ address: String) -> InterfaceAddress {
        InterfaceAddress(interfaceName: name, address: address)
    }

    @Test(arguments: [
        ("utun4", "10.8.0.2"),
        ("utun6", "fd00:1234::2"),
        ("ipsec0", "172.16.0.5"),
        ("ppp0", "192.168.99.2"),
        ("wg0", "10.66.66.2"),
        ("tun0", "2a01:4f8:c0c:1::2"),
    ])
    func tunnelWithRoutableAddressIsVPN(name: String, address: String) {
        let status = VPNDetector.detect([Self.interface("en0", "192.168.1.5"), Self.interface(name, address)])
        #expect(status == VPNStatus(interfaceName: name))
        #expect(status.isActive)
    }

    @Test func systemTunnelsWithLinkLocalOnlyAreNotVPN() {
        let interfaces = [
            Self.interface("en0", "192.168.1.5"),
            Self.interface("utun0", "fe80::1"),
            Self.interface("utun1", "fe80::2%utun1"),
            Self.interface("utun2", "169.254.10.1"),
        ]
        #expect(!VPNDetector.detect(interfaces).isActive)
    }

    @Test func physicalInterfacesAreNotVPN() {
        let interfaces = [Self.interface("en0", "10.8.0.2"), Self.interface("bridge0", "10.0.0.1")]
        #expect(VPNDetector.detect(interfaces) == VPNStatus(interfaceName: nil))
    }

    @Test func firstTunnelByNameIsReported() {
        let interfaces = [Self.interface("utun7", "10.0.0.7"), Self.interface("utun4", "10.0.0.4")]
        #expect(VPNDetector.detect(interfaces).interfaceName == "utun4")
    }
}
