import AppKit

enum StatusItemClick: Equatable {
    case openMenu
    case toggleHidden

    private static let pressedModifiers: NSEvent.ModifierFlags = [.shift, .control, .option, .command]

    static func action(modifiers: NSEvent.ModifierFlags, allowsHiding: Bool) -> StatusItemClick {
        allowsHiding && modifiers.intersection(pressedModifiers) == .option ? .toggleHidden : .openMenu
    }
}
