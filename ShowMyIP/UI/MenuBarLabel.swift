enum MenuBarLabel: Equatable {
    case text(String)
    case symbol(String)

    private static let unknownCountryEmoji = "🌐"

    static func make(
        for status: AppState.Status,
        isCompact: Bool = false,
        compactStyle: CompactStyle = .flag,
        isHidden: Bool = false
    ) -> MenuBarLabel {
        switch status {
        case .loading:
            .symbol("globe")
        case .offline:
            .symbol("wifi.slash")
        case .failed:
            .symbol("exclamationmark.triangle")
        case .loaded(let info):
            loadedLabel(for: info, isCompact: isCompact, compactStyle: compactStyle, isHidden: isHidden)
        }
    }

    private static func loadedLabel(
        for info: IPInfo,
        isCompact: Bool,
        compactStyle: CompactStyle,
        isHidden: Bool
    ) -> MenuBarLabel {
        let address = isHidden ? PrivacyPreferences.masked(info.address.value) : info.address.value
        guard let country = info.country else {
            return isCompact ? .text(unknownCountryEmoji) : .text("\(unknownCountryEmoji) \(address)")
        }
        guard isCompact else {
            return .text("\(country.flagEmoji) \(address)")
        }
        switch compactStyle {
        case .flag:
            return .text(country.flagEmoji)
        case .flagAndCountryCode:
            return .text("\(country.flagEmoji) \(country.value)")
        }
    }
}
