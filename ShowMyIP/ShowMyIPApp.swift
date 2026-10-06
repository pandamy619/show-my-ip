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
    @AppStorage("displayMode") private var displayMode: DisplayMode = .automatic

    var body: some Scene {
        MenuBarExtra {
            Button("Refresh") {
                Task { await appState.refresh() }
            }
            .keyboardShortcut("r")
            Picker("Display", selection: $displayMode) {
                ForEach(DisplayMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
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
        }
    }

    private var menuBarLabel: MenuBarLabel {
        let isCompact = displayMode.isCompact(hasNotchedScreen: screenObserver.hasNotchedScreen)
        return MenuBarLabel.make(for: appState.status, isCompact: isCompact)
    }
}
