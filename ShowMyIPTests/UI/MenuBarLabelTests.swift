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

    @Test func preferredIPv6IsShownWhenAvailable() throws {
        let ipv4 = try #require(IPAddress("185.23.45.67"))
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let info = IPInfo(address: ipv4, country: CountryCode("NL"), secondaryAddress: ipv6)
        #expect(MenuBarLabel.make(for: .loaded(info), preferredVersion: .v6) == .text("🇳🇱 2a01:4f8:c0c:1::1"))
        #expect(MenuBarLabel.make(for: .loaded(info), preferredVersion: .v4) == .text("🇳🇱 185.23.45.67"))
    }

    @Test func preferredIPv6FallsBackToAvailableAddress() throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        #expect(MenuBarLabel.make(for: .loaded(info), preferredVersion: .v6) == .text("🇳🇱 185.23.45.67"))
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
