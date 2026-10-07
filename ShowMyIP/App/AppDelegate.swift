import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState(
        provider: FallbackIPProvider(
            primary: CloudflareIPProvider(client: URLSessionHTTPClient()),
            fallbacks: [IPInfoIOProvider(client: URLSessionHTTPClient())]
        ),
        networkMonitor: NWPathNetworkMonitor()
    )
    private let screenObserver = ScreenObserver()
    private let privacyState = PrivacyState()
    private let notificationCoordinator = NotificationCoordinator(sender: UserNotificationSender())
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settingsWindowController = SettingsWindowController(
            appState: appState,
            notificationCoordinator: notificationCoordinator
        )
        statusItemController = StatusItemController(
            appState: appState,
            screenObserver: screenObserver,
            privacyState: privacyState,
            notificationCoordinator: notificationCoordinator,
            settingsWindowController: settingsWindowController
        )
        appState.start()
        screenObserver.start()
    }
}
