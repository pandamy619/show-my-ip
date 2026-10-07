import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    private let appState: AppState
    private let notificationCoordinator: NotificationCoordinator
    private var window: NSWindow?

    init(appState: AppState, notificationCoordinator: NotificationCoordinator) {
        self.appState = appState
        self.notificationCoordinator = notificationCoordinator
    }

    func show() {
        let window = window ?? makeWindow()
        self.window = window
        NSApplication.shared.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let rootView = SettingsRootView(appState: appState, notificationCoordinator: notificationCoordinator)
        let controller = NSHostingController(rootView: rootView)
        controller.sizingOptions = [.preferredContentSize]
        let window = NSWindow(contentViewController: controller)
        window.title = "Show My IP Settings"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.toolbarStyle = .unified
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}

private struct SettingsRootView: View {
    let appState: AppState
    let notificationCoordinator: NotificationCoordinator

    var body: some View {
        SettingsView(currentCountry: currentCountry, notificationCoordinator: notificationCoordinator)
    }

    private var currentCountry: CountryCode? {
        guard case .loaded(let info) = appState.status else {
            return nil
        }
        return info.country
    }
}
