enum CompactStyle: String, CaseIterable, Identifiable, Sendable {
    case flag
    case flagAndCountryCode

    var id: Self { self }

    var title: String {
        switch self {
        case .flag:
            String(localized: "Flag")
        case .flagAndCountryCode:
            String(localized: "Flag and Country Code")
        }
    }
}
