import Foundation
import Observation

@MainActor
@Observable
final class PrivacyState {
    private(set) var isHidden: Bool

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let preferences = PrivacyPreferences.load(from: defaults)
        isHidden = preferences.allowsHiding && preferences.hidesOnLaunch
    }

    var allowsHiding: Bool {
        PrivacyPreferences.load(from: defaults).allowsHiding
    }

    func toggle() {
        guard allowsHiding else {
            isHidden = false
            return
        }
        isHidden.toggle()
    }

    @discardableResult
    func setHidden(_ hidden: Bool) -> Bool {
        guard allowsHiding else {
            isHidden = false
            return false
        }
        isHidden = hidden
        return true
    }

    func preferencesDidChange() {
        if !allowsHiding, isHidden {
            isHidden = false
        }
    }
}
