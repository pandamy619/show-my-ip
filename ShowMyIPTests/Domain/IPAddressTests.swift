import Testing

@testable import ShowMyIP

struct IPAddressTests {
    @Test(arguments: ["8.8.8.8", "185.23.45.67", "0.0.0.0"])
    func detectsIPv4(rawValue: String) throws {
        let address = try #require(IPAddress(rawValue))
        #expect(address.version == .v4)
        #expect(address.value == rawValue)
    }

    @Test(arguments: ["2a01:4f8:c0c:1::1", "::1", "::ffff:8.8.8.8"])
    func detectsIPv6(rawValue: String) throws {
        let address = try #require(IPAddress(rawValue))
        #expect(address.version == .v6)
        #expect(address.value == rawValue)
    }

    @Test(arguments: [
        "",
        "999.1.1.1",
        "1.2.3",
        "abc",
        " 8.8.8.8",
        "8.8.8.8 ",
        "<script>",
        "fe80::1%en0",
        "8.8.8.8\0evil",
    ])
    func invalidInputIsRejected(rawValue: String) {
        #expect(IPAddress(rawValue) == nil)
    }

    @Test func overlongInputIsRejected() {
        let overlong = String(repeating: "1:", count: 23)
        #expect(IPAddress(overlong) == nil)
    }

    @Test(arguments: [
        ("2a01:4f8:c0c:1::1", true),
        ("3fff::1", true),
        ("fe80::1", false),
        ("fd12:3456::1", false),
        ("::1", false),
        ("185.23.45.67", false),
    ])
    func detectsGlobalIPv6(address: String, isGlobal: Bool) throws {
        #expect(try #require(IPAddress(address)).isGlobalIPv6 == isGlobal)
    }
}
