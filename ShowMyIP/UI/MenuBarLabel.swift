enum MenuBarLabel: Equatable {
    case text(String)
    case symbol(String)

    private static let unknownCountryEmoji = "🌐"

    static func make(for status: AppState.Status, isCompact: Bool = false) -> MenuBarLabel {
        switch status {
        case .loading:
            .symbol("globe")
        case .offline:
            .symbol("wifi.slash")
        case .failed:
            .symbol("exclamationmark.triangle")
        case .loaded(let info):
            loadedLabel(for: info, isCompact: isCompact)
        }
    }

    private static func loadedLabel(for info: IPInfo, isCompact: Bool) -> MenuBarLabel {
        let flag = info.country?.flagEmoji ?? unknownCountryEmoji
        return isCompact ? .text(flag) : .text("\(flag) \(info.address.value)")
    }
}
