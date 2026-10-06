import Testing

@testable import ShowMyIP

struct CountryCodeTests {
    @Test(arguments: [
        ("NL", "🇳🇱"),
        ("DE", "🇩🇪"),
        ("RU", "🇷🇺"),
        ("US", "🇺🇸"),
    ])
    func flagEmojiMatchesCountry(code: String, expectedFlag: String) throws {
        let countryCode = try #require(CountryCode(code))
        #expect(countryCode.flagEmoji == expectedFlag)
    }

    @Test func lowercaseInputIsNormalized() throws {
        let countryCode = try #require(CountryCode("nl"))
        #expect(countryCode.value == "NL")
    }

    @Test(arguments: ["", "N", "NLD", "T1", "1N", "N L", " NL", "NL\n", "ÄÖ", "ß", "🇳🇱"])
    func invalidInputIsRejected(rawValue: String) {
        #expect(CountryCode(rawValue) == nil)
    }
}
