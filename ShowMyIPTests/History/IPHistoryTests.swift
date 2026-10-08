import Foundation
import Testing

@testable import ShowMyIP

@MainActor
struct IPHistoryTests {
    private let defaults: UserDefaults
    private let start = Date(timeIntervalSince1970: 1_790_000_000)

    init() throws {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test func recordsFirstAddress() throws {
        let history = IPHistory(defaults: defaults)
        history.record(try .fixture(address: "185.23.45.67", country: "NL"), at: start)
        #expect(history.entries == [IPHistoryEntry(address: "185.23.45.67", country: "NL", date: start)])
    }

    @Test func sameAddressIsNotRecordedTwice() throws {
        let history = IPHistory(defaults: defaults)
        history.record(try .fixture(address: "185.23.45.67", country: "NL"), at: start)
        history.record(try .fixture(address: "185.23.45.67", country: "NL"), at: start + 60)
        #expect(history.entries.count == 1)
    }

    @Test func newestChangeComesFirst() throws {
        let history = IPHistory(defaults: defaults)
        history.record(try .fixture(address: "185.23.45.67", country: "NL"), at: start)
        history.record(try .fixture(address: "8.8.8.8", country: "US"), at: start + 60)
        #expect(history.entries.map(\.address) == ["8.8.8.8", "185.23.45.67"])
    }

    @Test func keepsOnlyNewestEntries() throws {
        let history = IPHistory(defaults: defaults)
        for index in 0...IPHistory.capacity {
            history.record(try .fixture(address: "10.0.0.\(index)"), at: start + Double(index))
        }
        #expect(history.entries.count == IPHistory.capacity)
        #expect(history.entries.first?.address == "10.0.0.\(IPHistory.capacity)")
        #expect(history.entries.last?.address == "10.0.0.1")
    }

    @Test func persistsBetweenLaunches() throws {
        IPHistory(defaults: defaults).record(try .fixture(address: "185.23.45.67", country: "NL"), at: start)
        #expect(IPHistory(defaults: defaults).entries.map(\.address) == ["185.23.45.67"])
    }

    @Test func clearRemovesEverything() throws {
        let history = IPHistory(defaults: defaults)
        history.record(try .fixture(address: "185.23.45.67"), at: start)
        history.clear()
        #expect(history.entries.isEmpty)
        #expect(IPHistory(defaults: defaults).entries.isEmpty)
    }

    @Test func disabledHistoryDoesNotRecord() throws {
        defaults.set(false, forKey: SettingsKey.keepsHistory)
        let history = IPHistory(defaults: defaults)
        history.record(try .fixture(address: "185.23.45.67"), at: start)
        #expect(history.entries.isEmpty)
    }

    @Test func disablingHistoryErasesIt() throws {
        let history = IPHistory(defaults: defaults)
        history.record(try .fixture(address: "185.23.45.67"), at: start)
        defaults.set(false, forKey: SettingsKey.keepsHistory)
        history.preferencesDidChange()
        #expect(history.entries.isEmpty)
        #expect(IPHistory(defaults: defaults).entries.isEmpty)
    }

    @Test func corruptedStorageGivesEmptyHistory() {
        defaults.set(Data("not json".utf8), forKey: IPHistory.storageKey)
        #expect(IPHistory(defaults: defaults).entries.isEmpty)
    }

    @Test func invalidStoredAddressesAreDropped() throws {
        let stored = [
            IPHistoryEntry(address: "<script>", country: nil, date: start),
            IPHistoryEntry(address: "185.23.45.67", country: "NL", date: start),
        ]
        defaults.set(try JSONEncoder().encode(stored), forKey: IPHistory.storageKey)
        #expect(IPHistory(defaults: defaults).entries.map(\.address) == ["185.23.45.67"])
    }
}
