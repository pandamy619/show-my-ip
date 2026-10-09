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

    private static func dualStack(ipv4Country: String?, ipv6Country: String?) throws -> IPInfo {
        let ipv4 = try #require(IPAddress("185.23.45.67"))
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        return IPInfo(address: ipv4, country: ipv4Country.flatMap(CountryCode.init))
            .withSecondaryAddress(ipv6, country: ipv6Country.flatMap(CountryCode.init))
    }

    @Test func differentIPv6CountryIsALeak() throws {
        let info = try Self.dualStack(ipv4Country: "NL", ipv6Country: "RU")
        #expect(info.leakedIPv6Country == CountryCode("RU"))
    }

    @Test(arguments: [("NL", "NL"), ("NL", nil), (nil, "RU")] as [(String?, String?)])
    func noLeakWithoutDifferentKnownCountries(ipv4Country: String?, ipv6Country: String?) throws {
        let info = try Self.dualStack(ipv4Country: ipv4Country, ipv6Country: ipv6Country)
        #expect(info.leakedIPv6Country == nil)
    }

    @Test func singleAddressHasNoLeak() throws {
        #expect(try IPInfo.fixture(address: "185.23.45.67", country: "NL").leakedIPv6Country == nil)
    }
}
