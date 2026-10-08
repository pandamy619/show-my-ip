import Testing

@testable import ShowMyIP

struct IPInfoTests {
    @Test func listsPrimaryThenSecondaryAddress() throws {
        let ipv4 = try #require(IPAddress("185.23.45.67"))
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let info = IPInfo(address: ipv4, country: nil, secondaryAddress: ipv6)
        #expect(info.addresses == [ipv4, ipv6])
    }

    @Test func findsAddressByVersion() throws {
        let ipv4 = try #require(IPAddress("185.23.45.67"))
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let info = IPInfo(address: ipv4, country: nil, secondaryAddress: ipv6)
        #expect(info.address(of: .v4) == ipv4)
        #expect(info.address(of: .v6) == ipv6)
    }

    @Test func missingVersionGivesNil() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67")
        #expect(info.addresses.count == 1)
        #expect(info.address(of: .v6) == nil)
    }
}
