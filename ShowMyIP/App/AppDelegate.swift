import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppState(provider: AppDelegate.makeProvider(), networkMonitor: NWPathNetworkMonitor())
    private let screenObserver = ScreenObserver()
    private let privacyState = PrivacyState()
    private let history = IPHistory()
    private let notificationCoordinator = NotificationCoordinator(sender: UserNotificationSender())
    private var statusItemController: StatusItemController?

    private static func makeProvider() -> any IPProvider {
        let ipInfo = IPInfoIOProvider(client: URLSessionHTTPClient())
        let dualStack = DualStackIPProvider(
            ipv4: FallbackIPProvider(
                primary: CloudflareIPProvider(
                    client: URLSessionHTTPClient(),
                    traceAddress: CloudflareIPProvider.ipv4TraceAddress
                ),
                fallbacks: [CloudflareIPProvider(client: URLSessionHTTPClient()), ipInfo]
            ),
            ipv6: CloudflareIPProvider(
                client: URLSessionHTTPClient(timeout: 5),
                traceAddress: CloudflareIPProvider.ipv6TraceAddress
            ),
            isIPv6Available: LocalAddressReader.hasGlobalIPv6
        )
        return DetailsEnrichingIPProvider(
            base: dualStack,
            details: ipInfo,
            isEnabled: { UserDefaults.standard.bool(forKey: SettingsKey.showsLocationDetails) }
        )
    }

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
            settingsWindowController: settingsWindowController,
            history: history
        )
        appState.start()
        screenObserver.start()
    }
}
