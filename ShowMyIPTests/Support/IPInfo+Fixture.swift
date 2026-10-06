@testable import ShowMyIP

struct InvalidFixture: Error {}

extension IPInfo {
    static func fixture(address: String, country: String? = nil) throws -> IPInfo {
        guard let ipAddress = IPAddress(address) else {
            throw InvalidFixture()
        }
        return IPInfo(address: ipAddress, country: country.flatMap(CountryCode.init))
    }
}
