import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appState = AppDelegate.makeAppState()
    private let screenObserver = ScreenObserver()
    private let privacyState = PrivacyState()
    private let history = AppDelegate.makeHistory()
    private let notificationCoordinator = NotificationCoordinator(sender: UserNotificationSender())
    private var statusItemController: StatusItemController?

    private static func makeAppState() -> AppState {
        #if DEBUG
            if DemoMode.isEnabled {
                return AppState(
                    provider: DemoIPProvider(),
                    networkMonitor: NWPathNetworkMonitor(),
                    readLocalAddresses: { DemoMode.localAddresses },
                    readVPNStatus: { VPNStatus(interfaceName: "utun4") }
                )
            }
        #endif
        return AppState(provider: makeProvider(), networkMonitor: NWPathNetworkMonitor())
    }

    private static func makeHistory() -> IPHistory {
        #if DEBUG
            if DemoMode.isEnabled, let defaults = UserDefaults(suiteName: DemoMode.defaultsSuiteName) {
                defaults.removePersistentDomain(forName: DemoMode.defaultsSuiteName)
                return IPHistory(defaults: defaults)
            }
        #endif
        return IPHistory()
    }

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
        let enriched = DetailsEnrichingIPProvider(
            base: dualStack,
            details: ipInfo,
            isEnabled: { UserDefaults.standard.bool(forKey: SettingsKey.showsLocationDetails) }
        )
        return DNSCheckingIPProvider(
            base: enriched,
            lookup: SystemDNSResolverLookup(),
            details: ipInfo,
            isEnabled: { UserDefaults.standard.bool(forKey: SettingsKey.checksDNS) }
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
