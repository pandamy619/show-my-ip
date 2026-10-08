import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState(
        provider: DualStackIPProvider(
            ipv4: FallbackIPProvider(
                primary: CloudflareIPProvider(
                    client: URLSessionHTTPClient(),
                    traceAddress: CloudflareIPProvider.ipv4TraceAddress
                ),
                fallbacks: [
                    CloudflareIPProvider(client: URLSessionHTTPClient()),
                    IPInfoIOProvider(client: URLSessionHTTPClient()),
                ]
            ),
            ipv6: CloudflareIPProvider(
                client: URLSessionHTTPClient(timeout: 5),
                traceAddress: CloudflareIPProvider.ipv6TraceAddress
            )
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
