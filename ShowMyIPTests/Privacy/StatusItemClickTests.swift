import AppKit
import Testing

@testable import ShowMyIP

struct StatusItemClickTests {
    @Test func plainClickOpensMenu() {
        #expect(StatusItemClick.action(modifiers: [], allowsHiding: true) == .openMenu)
    }

    @Test func optionClickTogglesWhenAllowed() {
        #expect(StatusItemClick.action(modifiers: [.option], allowsHiding: true) == .toggleHidden)
    }

    @Test func optionClickOpensMenuWhenHidingIsNotAllowed() {
        #expect(StatusItemClick.action(modifiers: [.option], allowsHiding: false) == .openMenu)
    }

    @Test func otherModifiersOpenMenu() {
        #expect(StatusItemClick.action(modifiers: [.command], allowsHiding: true) == .openMenu)
    }

    private static let optionWithStateFlags: [NSEvent.ModifierFlags] = [
        [.option, .capsLock],
        [.option, .function],
        [.option, .numericPad],
        [.option, .help],
    ]

    private static let optionWithPressedModifier: [NSEvent.ModifierFlags] = [
        [.option, .shift],
        [.option, .command],
        [.option, .control],
    ]

    @Test(arguments: optionWithStateFlags)
    func optionClickIgnoresStateFlags(modifiers: NSEvent.ModifierFlags) {
        #expect(StatusItemClick.action(modifiers: modifiers, allowsHiding: true) == .toggleHidden)
    }

    @Test(arguments: optionWithPressedModifier)
    func optionWithAnotherModifierOpensMenu(modifiers: NSEvent.ModifierFlags) {
        #expect(StatusItemClick.action(modifiers: modifiers, allowsHiding: true) == .openMenu)
    }
}
