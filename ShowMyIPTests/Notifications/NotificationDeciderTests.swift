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

    private func leaking(_ ipv6Country: String = "RU") throws -> AppState.Status {
        let ipv6 = try #require(IPAddress("2a01:4f8:c0c:1::1"))
        let info = try IPInfo.fixture(address: "1.1.1.1", country: "NL")
            .withSecondaryAddress(ipv6, country: CountryCode(ipv6Country))
        return .loaded(info)
    }

    private func expectedLeak() throws -> IPNotification {
        let netherlands = try #require(CountryCode("NL"))
        let russia = try #require(CountryCode("RU"))
        return .ipv6Leak(ipv4Country: netherlands, ipv6Country: russia)
    }

    @Test func ipv6LeakNotifiesEvenOnFirstLoad() throws {
        #expect(decide([try leaking()]) == [try expectedLeak()])
    }

    @Test func ipv6LeakNotifiesWhenItStarts() throws {
        let result = decide([try loaded("1.1.1.1", "NL"), try leaking()])
        #expect(result.last == .some(try expectedLeak()))
    }

    @Test func ongoingIPv6LeakIsSilent() throws {
        #expect(decide([try leaking(), try leaking()]).last == .some(nil))
    }

    @Test func ipv6LeakIsSilentWhenDisabled() throws {
        var preferences = defaults
        preferences.notifiesIPv6Leak = false
        #expect(decide([try leaking()], preferences: preferences) == [nil])
    }
}
