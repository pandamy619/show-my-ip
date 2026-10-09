import Testing

@testable import ShowMyIP

struct CoordinateTests {
    @Test func parsesIPInfoLocation() throws {
        let coordinate = try #require(Coordinate(ipinfoLocation: "52.3740,4.8897"))
        #expect(coordinate.latitude == 52.374)
        #expect(coordinate.longitude == 4.8897)
    }

    @Test(arguments: ["", "abc", "52.37", "52.37,4.89,1", "100,0", "0,200", "nan,0", "inf,0", " 52.37,4.89"])
    func rejectsInvalidLocation(location: String) {
        #expect(Coordinate(ipinfoLocation: location) == nil)
    }

    @Test func rejectsOutOfRangeValues() {
        #expect(Coordinate(latitude: -91, longitude: 0) == nil)
        #expect(Coordinate(latitude: 0, longitude: 181) == nil)
        #expect(Coordinate(latitude: 90, longitude: -180) != nil)
    }
}
