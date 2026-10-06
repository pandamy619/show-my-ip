import Testing

@testable import ShowMyIP

struct DisplayModeTests {
    @Test func automaticIsCompactOnNotchedScreen() {
        #expect(DisplayMode.automatic.isCompact(hasNotchedScreen: true))
    }

    @Test func automaticIsFullWithoutNotch() {
        #expect(!DisplayMode.automatic.isCompact(hasNotchedScreen: false))
    }

    @Test(arguments: [true, false])
    func compactIsAlwaysCompact(hasNotchedScreen: Bool) {
        #expect(DisplayMode.compact.isCompact(hasNotchedScreen: hasNotchedScreen))
    }

    @Test(arguments: [true, false])
    func fullIsNeverCompact(hasNotchedScreen: Bool) {
        #expect(!DisplayMode.full.isCompact(hasNotchedScreen: hasNotchedScreen))
    }
}
