import SwiftUI

@main
struct ShowMyIPApp: App {
    @State private var appState = AppState(
        provider: FallbackIPProvider(
            primary: CloudflareIPProvider(client: URLSessionHTTPClient()),
            fallbacks: [IPInfoIOProvider(client: URLSessionHTTPClient())]
        ),
        networkMonitor: NWPathNetworkMonitor()
    )
    @State private var screenObserver = ScreenObserver()
    @State private var notificationCoordinator = NotificationCoordinator(sender: UserNotificationSender())
    @AppStorage("displayMode") private var displayMode: DisplayMode = .automatic
    @AppStorage("compactStyle") private var compactStyle: CompactStyle = .flag

    var body: some Scene {
        MenuBarExtra {
            MenuInfoView(
                items: MenuInfoBuilder.items(
                    for: appState.status,
                    localAddresses: appState.localAddresses,
                    locale: .current
                )
            )
            Divider()
            Button("Refresh") {
                Task { await appState.refresh() }
            }
            .keyboardShortcut("r")
            Picker("Display", selection: $displayMode) {
                ForEach(DisplayMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            Picker("Compact Style", selection: $compactStyle) {
                ForEach(CompactStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            NotificationsMenu(
                currentCountry: currentCountry,
                requestAuthorization: { await notificationCoordinator.requestAuthorization() }
            )
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            MenuBarLabelView(label: menuBarLabel)
                .task {
                    appState.start()
                    screenObserver.start()
                }
                .onChange(of: appState.status) { _, newStatus in
                    notificationCoordinator.handle(newStatus, preferences: .load(from: .standard))
                }
        }
    }

    private var menuBarLabel: MenuBarLabel {
        let isCompact = displayMode.isCompact(hasNotchedScreen: screenObserver.hasNotchedScreen)
        return MenuBarLabel.make(for: appState.status, isCompact: isCompact, compactStyle: compactStyle)
    }

    private var currentCountry: CountryCode? {
        guard case .loaded(let info) = appState.status else {
            return nil
        }
        return info.country
    }
}
