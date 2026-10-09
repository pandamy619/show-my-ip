import Testing

@testable import ShowMyIP

struct CountryRegionsTests {
    @Test func coversMostCountries() {
        #expect(CountryRegions.count > 200)
    }

    @Test func netherlandsRegionContainsAmsterdam() throws {
        let netherlands = try #require(CountryCode("NL"))
        let region = try #require(CountryRegions.region(for: netherlands))
        #expect(abs(region.center.latitude - 52.37) < region.latitudeSpan / 2)
        #expect(abs(region.center.longitude - 4.89) < region.longitudeSpan / 2)
    }

    @Test func unknownCountryHasNoRegion() throws {
        let unknown = try #require(CountryCode("ZZ"))
        #expect(CountryRegions.region(for: unknown) == nil)
    }
}
