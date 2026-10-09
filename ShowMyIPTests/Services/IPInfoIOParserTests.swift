import Foundation
import Testing

@testable import ShowMyIP

struct IPInfoIOParserTests {
    private static let sampleJSON = Data(
        """
        {
          "ip": "185.23.45.67",
          "city": "Amsterdam",
          "region": "North Holland",
          "country": "NL",
          "org": "AS1234 Example ISP",
          "loc": "52.3740,4.8897",
          "timezone": "Europe/Amsterdam"
        }
        """.utf8
    )

    @Test func parsesAllFields() throws {
        let info = try IPInfoIOParser.parse(Self.sampleJSON)
        #expect(info.address.value == "185.23.45.67")
        #expect(info.country == CountryCode("NL"))
        #expect(info.city == "Amsterdam")
        #expect(info.organization == "AS1234 Example ISP")
        #expect(info.coordinate == Coordinate(latitude: 52.374, longitude: 4.8897))
    }

    @Test func optionalFieldsMayBeAbsent() throws {
        let info = try IPInfoIOParser.parse(Data(#"{"ip": "8.8.8.8"}"#.utf8))
        #expect(info.country == nil)
        #expect(info.city == nil)
        #expect(info.organization == nil)
    }

    @Test func sanitizesTextFields() throws {
        let info = try IPInfoIOParser.parse(Data(#"{"ip": "8.8.8.8", "city": "Ams‮terdam\n"}"#.utf8))
        #expect(info.city == "Amsterdam")
    }

    @Test func invalidCountryIsIgnored() throws {
        let info = try IPInfoIOParser.parse(Data(#"{"ip": "8.8.8.8", "country": "N1"}"#.utf8))
        #expect(info.country == nil)
    }

    @Test(arguments: ["", "not json", "[]", #"{"ip": 42}"#])
    func malformedJSONThrows(body: String) {
        #expect(throws: IPInfoIOParser.ParseError.invalidJSON) {
            try IPInfoIOParser.parse(Data(body.utf8))
        }
    }

    @Test func missingAddressThrows() {
        #expect(throws: IPInfoIOParser.ParseError.missingIPAddress) {
            try IPInfoIOParser.parse(Data(#"{"country": "NL"}"#.utf8))
        }
    }

    @Test func invalidAddressThrows() {
        #expect(throws: IPInfoIOParser.ParseError.invalidIPAddress) {
            try IPInfoIOParser.parse(Data(#"{"ip": "<script>"}"#.utf8))
        }
    }
}
