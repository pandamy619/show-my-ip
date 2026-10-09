struct Coordinate: Equatable, Sendable {
    private static let latitudeRange = -90.0...90.0
    private static let longitudeRange = -180.0...180.0

    let latitude: Double
    let longitude: Double

    init?(latitude: Double, longitude: Double) {
        guard Self.latitudeRange.contains(latitude), Self.longitudeRange.contains(longitude) else {
            return nil
        }
        self.latitude = latitude
        self.longitude = longitude
    }

    init?(ipinfoLocation: String) {
        let parts = ipinfoLocation.split(separator: ",", omittingEmptySubsequences: false)
        guard parts.count == 2, let latitude = Double(parts[0]), let longitude = Double(parts[1]) else {
            return nil
        }
        self.init(latitude: latitude, longitude: longitude)
    }
}
