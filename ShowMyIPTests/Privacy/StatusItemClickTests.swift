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
}
