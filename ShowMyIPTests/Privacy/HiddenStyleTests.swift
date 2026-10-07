import Foundation
import Testing

@testable import ShowMyIP

struct HiddenStyleTests {
    @Test func defaultStyleIsAnimated() throws {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        #expect(PrivacyPreferences.load(from: defaults).hiddenStyle == .animated)
    }

    @Test func unknownStoredStyleFallsBackToAnimated() throws {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set("sparkles", forKey: PrivacyPreferences.Key.hiddenStyle)
        #expect(PrivacyPreferences.load(from: defaults).hiddenStyle == .animated)
    }

    @Test func storedStyleIsRead() throws {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(HiddenStyle.still.rawValue, forKey: PrivacyPreferences.Key.hiddenStyle)
        #expect(PrivacyPreferences.load(from: defaults).hiddenStyle == .still)
    }

    @Test func onlyAsterisksSkipSpoiler() {
        #expect(HiddenStyle.allCases.filter { !$0.usesSpoiler } == [.asterisks])
    }

    @Test(arguments: [
        (HiddenStyle.animated, false, true),
        (.animated, true, true),
        (.still, false, false),
        (.still, true, false),
        (.animatedOnHover, false, false),
        (.animatedOnHover, true, true),
        (.asterisks, true, false),
    ])
    func animationDependsOnStyleAndHover(style: HiddenStyle, isHovered: Bool, expected: Bool) {
        #expect(style.animates(isHovered: isHovered) == expected)
    }
}
