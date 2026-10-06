enum CompactStyle: String, CaseIterable, Identifiable, Sendable {
    case flag
    case flagAndCountryCode

    var id: Self { self }

    var title: String {
        switch self {
        case .flag:
            "Flag"
        case .flagAndCountryCode:
            "Flag and Country Code"
        }
    }
}
