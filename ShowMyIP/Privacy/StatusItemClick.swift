import AppKit

enum StatusItemClick: Equatable {
    case openMenu
    case toggleHidden

    static func action(modifiers: NSEvent.ModifierFlags, allowsHiding: Bool) -> StatusItemClick {
        let relevant = modifiers.intersection(.deviceIndependentFlagsMask)
        return allowsHiding && relevant == .option ? .toggleHidden : .openMenu
    }
}
