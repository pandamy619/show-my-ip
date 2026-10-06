enum CloudflareTraceParser {
    enum ParseError: Error, Equatable {
        case missingIPAddress
        case invalidIPAddress
    }

    private static let unknownCountryCode = "XX"

    static func parse(_ body: String) throws(ParseError) -> IPInfo {
        let fields = parseFields(body)
        guard let rawAddress = fields["ip"] else {
            throw .missingIPAddress
        }
        guard let address = IPAddress(rawAddress) else {
            throw .invalidIPAddress
        }
        return IPInfo(address: address, country: country(from: fields["loc"]))
    }

    private static func parseFields(_ body: String) -> [String: String] {
        var fields: [String: String] = [:]
        for line in body.split(whereSeparator: \.isNewline) {
            let parts = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else {
                continue
            }
            let key = String(parts[0])
            if fields[key] == nil {
                fields[key] = String(parts[1])
            }
        }
        return fields
    }

    private static func country(from rawValue: String?) -> CountryCode? {
        guard let rawValue, rawValue != unknownCountryCode else {
            return nil
        }
        return CountryCode(rawValue)
    }
}
