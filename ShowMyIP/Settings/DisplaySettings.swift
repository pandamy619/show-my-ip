import Foundation

struct DisplaySettings: Equatable, Sendable {
    let displayMode: DisplayMode
    let compactStyle: CompactStyle
    let menuBarAddress: MenuBarAddress
    let showsVPNBadge: Bool

    init(
        displayMode: DisplayMode,
        compactStyle: CompactStyle,
        menuBarAddress: MenuBarAddress = .ipv4,
        showsVPNBadge: Bool = false
    ) {
        self.displayMode = displayMode
        self.compactStyle = compactStyle
        self.menuBarAddress = menuBarAddress
        self.showsVPNBadge = showsVPNBadge
    }

    static func load(from defaults: UserDefaults) -> DisplaySettings {
        DisplaySettings(
            displayMode: defaults.string(forKey: SettingsKey.displayMode).flatMap(DisplayMode.init) ?? .automatic,
            compactStyle: defaults.string(forKey: SettingsKey.compactStyle).flatMap(CompactStyle.init) ?? .flag,
            menuBarAddress: defaults.string(forKey: SettingsKey.menuBarAddress).flatMap(MenuBarAddress.init) ?? .ipv4,
            showsVPNBadge: defaults.bool(forKey: SettingsKey.showsVPNBadge)
        )
    }
}
