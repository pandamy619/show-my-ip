import Testing

@testable import ShowMyIP

struct MenuBarLabelTests {
    @Test func loadingShowsGlobe() {
        #expect(MenuBarLabel.make(for: .loading) == .symbol("globe"))
    }

    @Test func offlineShowsNoWiFi() {
        #expect(MenuBarLabel.make(for: .offline) == .symbol("wifi.slash"))
    }

    @Test func failureShowsWarning() {
        #expect(MenuBarLabel.make(for: .failed(.network)) == .symbol("exclamationmark.triangle"))
    }

    @Test func loadedShowsFlagAndAddress() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        #expect(MenuBarLabel.make(for: .loaded(info)) == .text("🇳🇱 185.23.45.67"))
    }

    @Test func loadedWithoutCountryShowsGlobeEmoji() throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        #expect(MenuBarLabel.make(for: .loaded(info)) == .text("🌐 8.8.8.8"))
    }

    @Test func compactLoadedShowsOnlyFlag() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        #expect(MenuBarLabel.make(for: .loaded(info), isCompact: true) == .text("🇳🇱"))
    }

    @Test func compactLoadedWithoutCountryShowsGlobeEmoji() throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        #expect(MenuBarLabel.make(for: .loaded(info), isCompact: true) == .text("🌐"))
    }

    @Test func compactKeepsStatusSymbols() {
        #expect(MenuBarLabel.make(for: .offline, isCompact: true) == .symbol("wifi.slash"))
    }
}
