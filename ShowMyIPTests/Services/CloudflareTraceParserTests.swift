import Testing

@testable import ShowMyIP

struct CloudflareTraceParserTests {
    private static let sampleTrace = """
        fl=123f45
        h=1.1.1.1
        ip=185.23.45.67
        ts=1759760000.123
        visit_scheme=https
        colo=AMS
        loc=NL
        tls=TLSv1.3
        """

    @Test func parsesAddressAndCountry() throws {
        let info = try CloudflareTraceParser.parse(Self.sampleTrace)
        #expect(info.address.value == "185.23.45.67")
        #expect(info.address.version == .v4)
        #expect(info.country == CountryCode("NL"))
    }

    @Test func parsesIPv6Address() throws {
        let info = try CloudflareTraceParser.parse("ip=2a01:4f8:c0c:1::1\nloc=DE")
        #expect(info.address.version == .v6)
        #expect(info.country == CountryCode("DE"))
    }

    @Test func parsesCRLFLineEndings() throws {
        let info = try CloudflareTraceParser.parse("ip=8.8.8.8\r\nloc=US\r\n")
        #expect(info.address.value == "8.8.8.8")
        #expect(info.country == CountryCode("US"))
    }

    @Test func firstOccurrenceOfKeyWins() throws {
        let info = try CloudflareTraceParser.parse("ip=8.8.8.8\nip=1.1.1.1")
        #expect(info.address.value == "8.8.8.8")
    }

    @Test(arguments: ["ip=8.8.8.8", "ip=8.8.8.8\nloc=XX", "ip=8.8.8.8\nloc=T1", "ip=8.8.8.8\nloc="])
    func unknownCountryIsNil(body: String) throws {
        let info = try CloudflareTraceParser.parse(body)
        #expect(info.country == nil)
    }

    @Test(arguments: ["", "loc=NL", "garbage", "IP=8.8.8.8"])
    func missingAddressThrows(body: String) {
        #expect(throws: CloudflareTraceParser.ParseError.missingIPAddress) {
            try CloudflareTraceParser.parse(body)
        }
    }

    @Test(arguments: ["ip=", "ip=999.1.1.1", "ip=abc", "ip= 8.8.8.8", "ip=<script>"])
    func invalidAddressThrows(body: String) {
        #expect(throws: CloudflareTraceParser.ParseError.invalidIPAddress) {
            try CloudflareTraceParser.parse(body)
        }
    }
}
