import Foundation
import Testing

@testable import ShowMyIP

struct HistoryMenuBuilderTests {
    private let locale = Locale(identifier: "en_GB")
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }()
    private let now = Date(timeIntervalSince1970: 1_791_403_200)

    private func items(for entries: [IPHistoryEntry], isHidden: Bool = false) -> [MenuInfoItem] {
        HistoryMenuBuilder.items(for: entries, now: now, calendar: calendar, locale: locale, isHidden: isHidden)
    }

    @Test func emptyHistoryGivesNoItems() {
        #expect(items(for: []).isEmpty)
    }

    @Test func todayShowsTimeFlagAndAddress() throws {
        let afternoon = Date(timeIntervalSince1970: 1_791_383_520)
        let entry = IPHistoryEntry(address: "185.23.45.67", country: "NL", date: afternoon)
        let item = try #require(items(for: [entry]).first)
        #expect(item.title.hasPrefix("14:32"))
        #expect(item.title.hasSuffix("🇳🇱 185.23.45.67"))
        #expect(item.copyValue == "185.23.45.67")
    }

    @Test func earlierDaysIncludeDate() throws {
        let entry = IPHistoryEntry(address: "8.8.8.8", country: nil, date: now - 86_400)
        let item = try #require(items(for: [entry]).first)
        #expect(item.title.contains("Oct"))
        #expect(item.title.hasSuffix("🌐 8.8.8.8"))
    }

    @Test func showsOnlyNewestEntries() {
        let entries = (0..<15).map { IPHistoryEntry(address: "10.0.0.\($0)", country: nil, date: now) }
        let result = items(for: entries)
        #expect(result.count == HistoryMenuBuilder.visibleCount)
        #expect(result.first?.copyValue == "10.0.0.0")
    }

    @Test func hiddenMasksAddressesButKeepsThemCopyable() throws {
        let entry = IPHistoryEntry(address: "185.23.45.67", country: "NL", date: now)
        let item = try #require(items(for: [entry], isHidden: true).first)
        #expect(item.maskedSuffix == "***.**.**.**")
        #expect(item.title.hasSuffix("🇳🇱 ***.**.**.**"))
        #expect(item.copyValue == "185.23.45.67")
    }
}
