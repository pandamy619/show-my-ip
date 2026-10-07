enum HiddenStyle: String, CaseIterable, Identifiable, Sendable {
    case animated
    case still
    case animatedOnHover
    case asterisks

    var id: Self { self }

    var title: String {
        switch self {
        case .animated:
            "Animated spoiler"
        case .still:
            "Still spoiler"
        case .animatedOnHover:
            "Spoiler, animated on hover"
        case .asterisks:
            "Asterisks"
        }
    }

    var usesSpoiler: Bool {
        self != .asterisks
    }

    func animates(isHovered: Bool) -> Bool {
        switch self {
        case .animated:
            true
        case .animatedOnHover:
            isHovered
        case .still, .asterisks:
            false
        }
    }
}
