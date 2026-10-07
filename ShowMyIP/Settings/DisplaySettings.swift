import Foundation

struct DisplaySettings: Equatable, Sendable {
    let displayMode: DisplayMode
    let compactStyle: CompactStyle

    static func load(from defaults: UserDefaults) -> DisplaySettings {
        DisplaySettings(
            displayMode: defaults.string(forKey: SettingsKey.displayMode).flatMap(DisplayMode.init) ?? .automatic,
            compactStyle: defaults.string(forKey: SettingsKey.compactStyle).flatMap(CompactStyle.init) ?? .flag
        )
    }
}
