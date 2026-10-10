import Foundation
import Testing

@testable import ShowMyIP

@MainActor
struct PrivacyStateTests {
    private func makeDefaults(allowsHiding: Bool? = nil, hidesOnLaunch: Bool? = nil) throws -> UserDefaults {
        let suiteName = "ShowMyIPTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        if let allowsHiding {
            defaults.set(allowsHiding, forKey: PrivacyPreferences.Key.allowsHiding)
        }
        if let hidesOnLaunch {
            defaults.set(hidesOnLaunch, forKey: PrivacyPreferences.Key.hidesOnLaunch)
        }
        return defaults
    }

    @Test func preferencesDefaultToOff() throws {
        #expect(PrivacyPreferences.load(from: try makeDefaults()) == PrivacyPreferences())
    }

    @Test func startsHiddenOnlyWhenAllowedAndRequested() throws {
        #expect(PrivacyState(defaults: try makeDefaults(allowsHiding: true, hidesOnLaunch: true)).isHidden)
        #expect(!PrivacyState(defaults: try makeDefaults(allowsHiding: true, hidesOnLaunch: false)).isHidden)
        #expect(!PrivacyState(defaults: try makeDefaults(allowsHiding: false, hidesOnLaunch: true)).isHidden)
    }

    @Test func toggleFlipsWhenAllowed() throws {
        let state = PrivacyState(defaults: try makeDefaults(allowsHiding: true))
        state.toggle()
        #expect(state.isHidden)
        state.toggle()
        #expect(!state.isHidden)
    }

    @Test func toggleDoesNothingWhenNotAllowed() throws {
        let state = PrivacyState(defaults: try makeDefaults(allowsHiding: false))
        state.toggle()
        #expect(!state.isHidden)
    }

    @Test func disallowingHidingRevealsAddress() throws {
        let defaults = try makeDefaults(allowsHiding: true, hidesOnLaunch: true)
        let state = PrivacyState(defaults: defaults)
        defaults.set(false, forKey: PrivacyPreferences.Key.allowsHiding)
        state.preferencesDidChange()
        #expect(!state.isHidden)
    }

    @Test func setHiddenFollowsRequestWhenAllowed() throws {
        let state = PrivacyState(defaults: try makeDefaults(allowsHiding: true))
        #expect(state.setHidden(true))
        #expect(state.isHidden)
        #expect(state.setHidden(false))
        #expect(!state.isHidden)
    }

    @Test func setHiddenIsRefusedWhenHidingIsNotAllowed() throws {
        let state = PrivacyState(defaults: try makeDefaults(allowsHiding: false))
        #expect(!state.setHidden(true))
        #expect(!state.isHidden)
    }
}
