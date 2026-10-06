struct CountryCode: Equatable, Sendable {
    private static let regionalIndicatorSymbolA: UInt32 = 0x1F1E6
    private static let latinCapitalLetterA: UInt32 = 0x41

    let value: String

    init?(_ rawValue: String) {
        let scalars = rawValue.unicodeScalars
        guard scalars.count == 2, scalars.allSatisfy({ $0.isASCII && $0.properties.isAlphabetic }) else {
            return nil
        }
        value = rawValue.uppercased()
    }

    var flagEmoji: String {
        let offset = Self.regionalIndicatorSymbolA - Self.latinCapitalLetterA
        let indicators = value.unicodeScalars.compactMap { Unicode.Scalar($0.value + offset) }
        return String(String.UnicodeScalarView(indicators))
    }
}
