import Foundation

struct MapLocation: Equatable, Sendable {
    private static let citySpan = 0.6

    let region: MapRegion
    let title: String

    static func make(for info: IPInfo, locale: Locale) -> MapLocation? {
        let countryName = info.country.map { locale.localizedString(forRegionCode: $0.value) ?? $0.value }
        if let coordinate = info.coordinate {
            let region = MapRegion(center: coordinate, latitudeSpan: citySpan, longitudeSpan: citySpan)
            return MapLocation(region: region, title: info.city ?? countryName ?? "")
        }
        guard let country = info.country, let region = CountryRegions.region(for: country) else {
            return nil
        }
        return MapLocation(region: region, title: countryName ?? country.value)
    }

    var appleMapsURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(region.center.latitude),\(region.center.longitude)"),
            URLQueryItem(name: "spn", value: "\(region.latitudeSpan),\(region.longitudeSpan)"),
        ]
        return components.url
    }
}
