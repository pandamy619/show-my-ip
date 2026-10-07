import Foundation
import Testing

@testable import ShowMyIP

struct DisplaySettingsTests {
    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func emptyStorageGivesDefaults() throws {
        let settings = DisplaySettings.load(from: try makeDefaults())
        #expect(settings == DisplaySettings(displayMode: .automatic, compactStyle: .flag))
    }

    @Test func readsStoredValues() throws {
        let defaults = try makeDefaults()
        defaults.set(DisplayMode.full.rawValue, forKey: SettingsKey.displayMode)
        defaults.set(CompactStyle.flagAndCountryCode.rawValue, forKey: SettingsKey.compactStyle)
        let settings = DisplaySettings.load(from: defaults)
        #expect(settings == DisplaySettings(displayMode: .full, compactStyle: .flagAndCountryCode))
    }

    @Test func unknownValuesFallBackToDefaults() throws {
        let defaults = try makeDefaults()
        defaults.set("sideways", forKey: SettingsKey.displayMode)
        defaults.set(42, forKey: SettingsKey.compactStyle)
        let settings = DisplaySettings.load(from: defaults)
        #expect(settings == DisplaySettings(displayMode: .automatic, compactStyle: .flag))
    }
}
