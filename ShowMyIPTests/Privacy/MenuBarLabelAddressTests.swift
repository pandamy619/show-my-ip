import Testing

@testable import ShowMyIP

struct MenuBarLabelAddressTests {
    @Test func splitsFlagAndAddress() throws {
        let parts = try #require(MenuBarLabel.splitAddress(in: "🇳🇱 ***.***.***.***"))
        #expect(parts.prefix == "🇳🇱 ")
        #expect(parts.address == "***.***.***.***")
    }

    @Test func textWithoutAddressIsNotSplit() {
        #expect(MenuBarLabel.splitAddress(in: "🇳🇱") == nil)
    }
}
