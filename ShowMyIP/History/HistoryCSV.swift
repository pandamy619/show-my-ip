import Foundation

enum HistoryCSV {
    private static let header = "date,ip,country"
    private static let formulaPrefixes: Set<Character> = ["=", "+", "-", "@"]
    private static let quotedCharacters: Set<Character> = [",", "\"", "\n", "\r"]

    static func make(from entries: [IPHistoryEntry]) -> String {
        let formatter = ISO8601DateFormatter()
        let rows = entries.sorted { $0.date < $1.date }.map { entry in
            [formatter.string(from: entry.date), entry.address, entry.country ?? ""].map(escape).joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n") + "\n"
    }

    static func escape(_ field: String) -> String {
        var value = field
        if let first = value.first, formulaPrefixes.contains(first) {
            value = "'" + value
        }
        guard value.contains(where: quotedCharacters.contains) else {
            return value
        }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
