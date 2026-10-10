import Foundation

enum ShortcutError: Error, CustomLocalizedStringResourceConvertible {
    case unavailable
    case hidingNotAllowed

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .unavailable:
            "Could not determine public IP"
        case .hidingNotAllowed:
            "Turn on “Allow hiding IP” in Show My IP settings first."
        }
    }
}
