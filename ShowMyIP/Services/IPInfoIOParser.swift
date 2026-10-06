import Foundation

enum IPInfoIOParser {
    enum ParseError: Error, Equatable {
        case invalidJSON
        case missingIPAddress
        case invalidIPAddress
    }

    private struct Payload: Decodable {
        let ip: String?
        let country: String?
        let city: String?
        let org: String?
    }

    static func parse(_ data: Data) throws(ParseError) -> IPInfo {
        let payload: Payload
        do {
            payload = try JSONDecoder().decode(Payload.self, from: data)
        } catch {
            throw .invalidJSON
        }
        guard let rawAddress = payload.ip else {
            throw .missingIPAddress
        }
        guard let address = IPAddress(rawAddress) else {
            throw .invalidIPAddress
        }
        return IPInfo(
            address: address,
            country: payload.country.flatMap(CountryCode.init),
            city: DisplayTextSanitizer.sanitize(payload.city),
            organization: DisplayTextSanitizer.sanitize(payload.org)
        )
    }
}
