import AppKit
import Observation

@MainActor
@Observable
final class ScreenObserver {
    private(set) var hasNotchedScreen: Bool

    @ObservationIgnored private var observationTask: Task<Void, Never>?

    init() {
        hasNotchedScreen = Self.anyScreenHasNotch()
    }

    func start() {
        guard observationTask == nil else {
            return
        }
        let screenChanges = NotificationCenter.default.notifications(
            named: NSApplication.didChangeScreenParametersNotification
        )
        observationTask = Task { [weak self] in
            for await _ in screenChanges {
                self?.hasNotchedScreen = Self.anyScreenHasNotch()
            }
        }
    }

    private static func anyScreenHasNotch() -> Bool {
        NSScreen.screens.contains { $0.safeAreaInsets.top > 0 }
    }
}
