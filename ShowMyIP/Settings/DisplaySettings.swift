import Foundation

struct DisplaySettings: Equatable, Sendable {
    let displayMode: DisplayMode
    let compactStyle: CompactStyle
    let menuBarAddress: MenuBarAddress

    init(displayMode: DisplayMode, compactStyle: CompactStyle, menuBarAddress: MenuBarAddress = .ipv4) {
        self.displayMode = displayMode
        self.compactStyle = compactStyle
        self.menuBarAddress = menuBarAddress
    }

    static func load(from defaults: UserDefaults) -> DisplaySettings {
        DisplaySettings(
            displayMode: defaults.string(forKey: SettingsKey.displayMode).flatMap(DisplayMode.init) ?? .automatic,
            compactStyle: defaults.string(forKey: SettingsKey.compactStyle).flatMap(CompactStyle.init) ?? .flag,
            menuBarAddress: defaults.string(forKey: SettingsKey.menuBarAddress).flatMap(MenuBarAddress.init) ?? .ipv4
        )
    }
}
