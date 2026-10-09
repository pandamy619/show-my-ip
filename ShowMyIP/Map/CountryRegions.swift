import Foundation

enum CountryRegions {
    private static let resourceName = "CountryRegions"
    private static let valuesPerRegion = 4

    private static let table: [String: [Double]] = {
        guard
            let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let table = try? JSONDecoder().decode([String: [Double]].self, from: data)
        else {
            AppLogger.ipLookup.error("Country regions are missing from the bundle")
            return [:]
        }
        return table
    }()

    static var count: Int {
        table.count
    }

    static func region(for country: CountryCode) -> MapRegion? {
        guard
            let values = table[country.value], values.count == valuesPerRegion,
            let center = Coordinate(latitude: values[0], longitude: values[1])
        else {
            return nil
        }
        return MapRegion(center: center, latitudeSpan: values[2], longitudeSpan: values[3])
    }
}
