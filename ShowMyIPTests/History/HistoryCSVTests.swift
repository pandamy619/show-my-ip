import Foundation
import Testing

@testable import ShowMyIP

struct HistoryCSVTests {
    private let first = Date(timeIntervalSince1970: 1_791_331_200)

    @Test func exportsOldestFirstWithHeader() {
        let entries = [
            IPHistoryEntry(address: "8.8.8.8", country: "US", date: first + 3_600),
            IPHistoryEntry(address: "185.23.45.67", country: nil, date: first),
        ]
        let expected = """
            date,ip,country
            2026-10-07T00:00:00Z,185.23.45.67,
            2026-10-07T01:00:00Z,8.8.8.8,US

            """
        #expect(HistoryCSV.make(from: entries) == expected)
    }

    @Test func emptyHistoryHasOnlyHeader() {
        #expect(HistoryCSV.make(from: []) == "date,ip,country\n")
    }

    @Test(arguments: [
        ("a,b", #""a,b""#),
        (#"say "hi""#, #""say ""hi""""#),
        ("=1+2", "'=1+2"),
        ("+7", "'+7"),
        ("-1", "'-1"),
        ("@cmd", "'@cmd"),
        ("NL", "NL"),
    ])
    func escapesUnsafeFields(field: String, expected: String) {
        #expect(HistoryCSV.escape(field) == expected)
    }
}
