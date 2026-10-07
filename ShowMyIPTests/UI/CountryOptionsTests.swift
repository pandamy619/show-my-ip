import Foundation
import Testing

@testable import ShowMyIP

struct CountryOptionsTests {
    private let options = CountryOptions.all(locale: Locale(identifier: "en_US"))

    @Test func containsKnownCountryWithLocalizedName() throws {
        let netherlands = try #require(options.first { $0.code == CountryCode("NL") })
        #expect(netherlands.name == "Netherlands")
        #expect(netherlands.title == "🇳🇱 Netherlands")
    }

    @Test func containsOnlyTwoLetterCountryCodes() {
        #expect(options.allSatisfy { $0.code.value.count == 2 })
        #expect(options.count > 200)
    }

    @Test func isSortedByName() {
        let names = options.map(\.name)
        #expect(names == names.sorted { $0.localizedStandardCompare($1) == .orderedAscending })
    }

    @Test func hasNoDuplicates() {
        #expect(Set(options.map(\.code.value)).count == options.count)
    }
}
