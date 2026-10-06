enum MenuBarLabel: Equatable {
    case text(String)
    case symbol(String)

    private static let unknownCountryEmoji = "🌐"

    static func make(for status: AppState.Status) -> MenuBarLabel {
        switch status {
        case .loading:
            .symbol("globe")
        case .offline:
            .symbol("wifi.slash")
        case .failed:
            .symbol("exclamationmark.triangle")
        case .loaded(let info):
            .text("\(info.country?.flagEmoji ?? unknownCountryEmoji) \(info.address.value)")
        }
    }
}
