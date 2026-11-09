import AppKit

enum StatusItemClick: Equatable {
    case openMenu
    case toggleHidden

    private static let pressedModifiers: NSEvent.ModifierFlags = [.shift, .control, .option, .command]

    static func action(
        modifiers: NSEvent.ModifierFlags,
        heldModifiers: NSEvent.ModifierFlags = [],
        allowsHiding: Bool
    ) -> StatusItemClick {
        let pressed = modifiers.union(heldModifiers).intersection(pressedModifiers)
        return allowsHiding && pressed == .option ? .toggleHidden : .openMenu
    }
}
