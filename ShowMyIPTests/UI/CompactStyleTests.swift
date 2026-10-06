import Testing

@testable import ShowMyIP

struct CompactStyleTests {
    @Test func flagAndCodeShowsFlagWithCountryCode() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let label = MenuBarLabel.make(for: .loaded(info), isCompact: true, compactStyle: .flagAndCountryCode)
        #expect(label == .text("🇳🇱 NL"))
    }

    @Test func flagAndCodeWithoutCountryShowsGlobeEmoji() throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        let label = MenuBarLabel.make(for: .loaded(info), isCompact: true, compactStyle: .flagAndCountryCode)
        #expect(label == .text("🌐"))
    }

    @Test func compactStyleIsIgnoredInFullMode() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let label = MenuBarLabel.make(for: .loaded(info), isCompact: false, compactStyle: .flagAndCountryCode)
        #expect(label == .text("🇳🇱 185.23.45.67"))
    }
}
