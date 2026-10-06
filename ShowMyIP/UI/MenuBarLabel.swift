enum MenuBarLabel: Equatable {
    case text(String)
    case symbol(String)

    private static let unknownCountryEmoji = "🌐"

    static func make(
        for status: AppState.Status,
        isCompact: Bool = false,
        compactStyle: CompactStyle = .flag
    ) -> MenuBarLabel {
        switch status {
        case .loading:
            .symbol("globe")
        case .offline:
            .symbol("wifi.slash")
        case .failed:
            .symbol("exclamationmark.triangle")
        case .loaded(let info):
            loadedLabel(for: info, isCompact: isCompact, compactStyle: compactStyle)
        }
    }

    private static func loadedLabel(for info: IPInfo, isCompact: Bool, compactStyle: CompactStyle) -> MenuBarLabel {
        guard let country = info.country else {
            return isCompact ? .text(unknownCountryEmoji) : .text("\(unknownCountryEmoji) \(info.address.value)")
        }
        guard isCompact else {
            return .text("\(country.flagEmoji) \(info.address.value)")
        }
        switch compactStyle {
        case .flag:
            return .text(country.flagEmoji)
        case .flagAndCountryCode:
            return .text("\(country.flagEmoji) \(country.value)")
        }
    }
}
