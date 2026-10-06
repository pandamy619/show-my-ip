import Testing

@testable import ShowMyIP

struct DisplayTextSanitizerTests {
    @Test func keepsRegularText() {
        #expect(DisplayTextSanitizer.sanitize("AS13335 Cloudflare, Inc.") == "AS13335 Cloudflare, Inc.")
    }

    @Test func keepsNonLatinText() {
        #expect(DisplayTextSanitizer.sanitize("Москва") == "Москва")
    }

    @Test func removesControlAndBidiCharacters() {
        #expect(DisplayTextSanitizer.sanitize("Amster\ndam\u{202E}\u{0007}") == "Amsterdam")
    }

    @Test func trimsWhitespace() {
        #expect(DisplayTextSanitizer.sanitize("  Berlin  ") == "Berlin")
    }

    @Test func truncatesLongText() {
        let long = String(repeating: "a", count: DisplayTextSanitizer.maximumLength + 10)
        #expect(DisplayTextSanitizer.sanitize(long)?.count == DisplayTextSanitizer.maximumLength)
    }

    @Test(arguments: [nil, "", "   ", "\n\t"] as [String?])
    func emptyInputBecomesNil(rawValue: String?) {
        #expect(DisplayTextSanitizer.sanitize(rawValue) == nil)
    }
}
