import Testing

@testable import ShowMyIP

struct IPInfoJSONTests {
    @Test func encodesAllKnownFieldsWithSortedKeys() throws {
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let info = IPInfo(
            address: try #require(IPAddress("185.23.45.67")),
            country: CountryCode("NL"),
            city: "Amsterdam",
            organization: "AS1 Example"
        )
        .withSecondaryAddress(ipv6, country: CountryCode("NL"))
        let json = IPInfoJSON.encode(info, vpnStatus: VPNStatus(interfaceName: "utun4"))
        let expected =
            #"{"city":"Amsterdam","country":"NL","ip":"185.23.45.67","ipv6":"2a01:4f8:c0c:1::1","#
            + #""provider":"AS1 Example","vpn":true}"#
        #expect(json == expected)
    }

    @Test func omitsUnknownFields() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67")
        #expect(IPInfoJSON.encode(info, vpnStatus: nil) == #"{"ip":"185.23.45.67"}"#)
    }

    @Test func reportsIPv6OnlyAddressAsIPv6() throws {
        let info = try IPInfo.fixture(address: "2a01:4f8:c0c:1::1", country: "DE")
        #expect(IPInfoJSON.encode(info, vpnStatus: nil) == #"{"country":"DE","ipv6":"2a01:4f8:c0c:1::1"}"#)
    }
}
