import Foundation

enum DisplayTextSanitizer {
    static let maximumLength = 64

    static func sanitize(_ rawValue: String?) -> String? {
        guard let rawValue else {
            return nil
        }
        let printableScalars = rawValue.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
        let cleaned = String(String.UnicodeScalarView(printableScalars))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            return nil
        }
        return String(cleaned.prefix(maximumLength))
    }
}
