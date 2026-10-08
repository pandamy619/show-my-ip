import Foundation

struct IPHistoryEntry: Codable, Equatable, Sendable {
    let address: String
    let country: String?
    let date: Date
}
