import Foundation
import Testing

@testable import ShowMyIP

struct MapLocationTests {
    private let locale = Locale(identifier: "en_US")

    @Test func cityCoordinateGivesCloseRegion() throws {
        let address = try #require(IPAddress("185.23.45.67"))
        let coordinate = try #require(Coordinate(latitude: 52.374, longitude: 4.8897))
        let info = IPInfo(address: address, country: CountryCode("NL"), city: "Amsterdam", coordinate: coordinate)
        let location = try #require(MapLocation.make(for: info, locale: locale))
        #expect(location.region.center == coordinate)
        #expect(location.region.latitudeSpan <= 1)
        #expect(location.title == "Amsterdam")
    }

    @Test func countryOnlyGivesCountryRegion() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let location = try #require(MapLocation.make(for: info, locale: locale))
        let netherlands = try #require(CountryCode("NL"))
        #expect(location.region == CountryRegions.region(for: netherlands))
        #expect(location.title == "Netherlands")
    }

    @Test func noCountryGivesNoLocation() throws {
        #expect(MapLocation.make(for: try IPInfo.fixture(address: "185.23.45.67"), locale: locale) == nil)
    }

    @Test func opensAppleMapsAtCenter() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let location = try #require(MapLocation.make(for: info, locale: locale))
        let url = try #require(location.appleMapsURL)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.scheme == "https")
        #expect(components.host == "maps.apple.com")
        let center = location.region.center
        let expected = URLQueryItem(name: "ll", value: "\(center.latitude),\(center.longitude)")
        #expect(components.queryItems?.contains(expected) == true)
    }
}
