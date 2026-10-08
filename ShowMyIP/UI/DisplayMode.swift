enum DisplayMode: String, CaseIterable, Identifiable, Sendable {
    case automatic
    case compact
    case full

    var id: Self { self }

    var title: String {
        switch self {
        case .automatic:
            String(localized: "Automatic")
        case .compact:
            String(localized: "Compact")
        case .full:
            String(localized: "Full")
        }
    }

    func isCompact(hasNotchedScreen: Bool) -> Bool {
        switch self {
        case .automatic:
            hasNotchedScreen
        case .compact:
            true
        case .full:
            false
        }
    }
}
