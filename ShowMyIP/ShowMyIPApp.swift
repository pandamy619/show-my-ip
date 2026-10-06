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

    var body: some Scene {
        MenuBarExtra {
            Button("Refresh") {
                Task { await appState.refresh() }
            }
            .keyboardShortcut("r")
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            MenuBarLabelView(label: MenuBarLabel.make(for: appState.status))
                .task { appState.start() }
        }
    }
}
