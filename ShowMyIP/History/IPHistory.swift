import Foundation

@MainActor
final class IPHistory {
    static let capacity = 50
    static let storageKey = "history.entries"

    private let defaults: UserDefaults
    private(set) var entries: [IPHistoryEntry]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        entries = Self.load(from: defaults)
    }

    var isEnabled: Bool {
        defaults.object(forKey: SettingsKey.keepsHistory) as? Bool ?? true
    }

    func record(_ info: IPInfo, at date: Date) {
        guard isEnabled, entries.first?.address != info.address.value else {
            return
        }
        let entry = IPHistoryEntry(address: info.address.value, country: info.country?.value, date: date)
        entries = Array(([entry] + entries).prefix(Self.capacity))
        save()
    }

    func clear() {
        entries = []
        defaults.removeObject(forKey: Self.storageKey)
    }

    func preferencesDidChange() {
        guard !isEnabled, !entries.isEmpty else {
            return
        }
        clear()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else {
            return
        }
        defaults.set(data, forKey: Self.storageKey)
    }

    private static func load(from defaults: UserDefaults) -> [IPHistoryEntry] {
        guard
            let data = defaults.data(forKey: storageKey),
            let stored = try? JSONDecoder().decode([IPHistoryEntry].self, from: data)
        else {
            return []
        }
        return Array(stored.filter { IPAddress($0.address) != nil }.prefix(capacity))
    }
}
