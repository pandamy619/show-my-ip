import Testing

@testable import ShowMyIP

struct NotificationDeciderTests {
    private let defaults = NotificationPreferences(isEnabled: true)

    private func loaded(_ address: String, _ country: String? = nil) throws -> AppState.Status {
        .loaded(try IPInfo.fixture(address: address, country: country))
    }

    private func decide(
        _ statuses: [AppState.Status],
        preferences: NotificationPreferences? = nil
    ) -> [IPNotification?] {
        var decider = NotificationDecider()
        return statuses.map { decider.process($0, preferences: preferences ?? defaults) }
    }

    @Test func firstLoadedStatusIsSilent() throws {
        #expect(decide([try loaded("1.1.1.1", "NL")]) == [nil])
    }

    @Test func countryChangeNotifies() throws {
        let result = decide([try loaded("1.1.1.1", "NL"), try loaded("2.2.2.2", "DE")])
        #expect(result.last == .countryChanged(from: CountryCode("NL"), to: CountryCode("DE")))
    }

    @Test func countryBecomingUnknownNotifies() throws {
        let result = decide([try loaded("1.1.1.1", "NL"), try loaded("2.2.2.2")])
        #expect(result.last == .countryChanged(from: CountryCode("NL"), to: nil))
    }

    @Test func addressChangeIsSilentByDefault() throws {
        #expect(decide([try loaded("1.1.1.1", "NL"), try loaded("2.2.2.2", "NL")]).last == .some(nil))
    }

    @Test func addressChangeNotifiesWhenEnabled() throws {
        var preferences = defaults
        preferences.notifiesAddressChange = true
        let result = decide([try loaded("1.1.1.1", "NL"), try loaded("2.2.2.2", "NL")], preferences: preferences)
        let expected = IPNotification.addressChanged(
            from: try #require(IPAddress("1.1.1.1")),
            to: try #require(IPAddress("2.2.2.2"))
        )
        #expect(result.last == expected)
    }

    @Test func homeCountryTakesPriorityOverCountryChange() throws {
        var preferences = defaults
        preferences.homeCountry = CountryCode("RU")
        let result = decide([try loaded("1.1.1.1", "NL"), try loaded("5.5.5.5", "RU")], preferences: preferences)
        #expect(result.last == .homeCountryDetected(try #require(CountryCode("RU"))))
    }

    @Test func homeCountryIsNotRepeatedWhileStayingHome() throws {
        var preferences = defaults
        preferences.homeCountry = CountryCode("RU")
        let statuses = [try loaded("1.1.1.1", "NL"), try loaded("5.5.5.5", "RU"), try loaded("6.6.6.6", "RU")]
        #expect(decide(statuses, preferences: preferences).last == .some(nil))
    }

    @Test func disabledHomeAlertFallsBackToCountryChange() throws {
        var preferences = defaults
        preferences.homeCountry = CountryCode("RU")
        preferences.notifiesHomeCountry = false
        let result = decide([try loaded("1.1.1.1", "NL"), try loaded("5.5.5.5", "RU")], preferences: preferences)
        #expect(result.last == .countryChanged(from: CountryCode("NL"), to: CountryCode("RU")))
    }

    @Test func disabledNotificationsAreSilentButKeepBaseline() throws {
        var decider = NotificationDecider()
        var preferences = defaults
        preferences.isEnabled = false
        _ = decider.process(try loaded("1.1.1.1", "NL"), preferences: preferences)
        #expect(decider.process(try loaded("2.2.2.2", "DE"), preferences: preferences) == nil)
        #expect(decider.process(try loaded("3.3.3.3", "DE"), preferences: defaults) == nil)
    }

    @Test func reconnectComparesWithLastKnownInfo() throws {
        let result = decide([try loaded("1.1.1.1", "NL"), .offline, try loaded("2.2.2.2", "DE")])
        #expect(result.last == .countryChanged(from: CountryCode("NL"), to: CountryCode("DE")))
    }

    @Test func failureKeepsBaseline() throws {
        let result = decide([try loaded("1.1.1.1", "NL"), .failed(.network), try loaded("2.2.2.2", "DE")])
        #expect(result == [nil, nil, .countryChanged(from: CountryCode("NL"), to: CountryCode("DE"))])
    }

    @Test func connectionLossIsSilentByDefault() throws {
        #expect(decide([try loaded("1.1.1.1", "NL"), .offline]).last == .some(nil))
    }

    @Test func connectionLossNotifiesOnceWhenEnabled() throws {
        var preferences = defaults
        preferences.notifiesConnectionLoss = true
        let result = decide([try loaded("1.1.1.1", "NL"), .offline, .offline], preferences: preferences)
        #expect(result == [nil, .connectionLost, nil])
    }

    @Test func offlineAtLaunchIsSilent() {
        var preferences = defaults
        preferences.notifiesConnectionLoss = true
        #expect(decide([.loading, .offline], preferences: preferences) == [nil, nil])
    }

    @Test func notificationsAreOffByDefault() {
        #expect(!NotificationPreferences().isEnabled)
    }
}
