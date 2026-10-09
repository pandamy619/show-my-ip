import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(SettingsKey.displayMode) private var displayMode: DisplayMode = .automatic
    @AppStorage(SettingsKey.compactStyle) private var compactStyle: CompactStyle = .flag
    @AppStorage(SettingsKey.menuBarAddress) private var menuBarAddress: MenuBarAddress = .ipv4
    @AppStorage(SettingsKey.showsLocationDetails) private var showsLocationDetails = false
    @AppStorage(SettingsKey.showsMap) private var showsMap = false
    @State private var launchAtLogin = LaunchAtLoginController(service: MainAppLoginItemService())

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: launchAtLoginBinding)
                if launchAtLogin.status == .requiresApproval {
                    Text("Allow Show My IP in System Settings to start it at login.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Open Login Items Settings") {
                        MainAppLoginItemService.openSystemSettings()
                    }
                }
                if launchAtLogin.didFail {
                    Text("Could not change the login item. Move the app to Applications and try again.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            Section("Menu bar") {
                Picker("Display", selection: $displayMode) {
                    ForEach(DisplayMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                Picker("Compact style", selection: $compactStyle) {
                    ForEach(CompactStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                Text("Automatic uses the compact style when a screen with a notch is connected.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Picker("Address", selection: $menuBarAddress) {
                    ForEach(MenuBarAddress.allCases) { address in
                        Text(address.title).tag(address)
                    }
                }
                .pickerStyle(.segmented)
                Text("If your network has no IPv6, the menu bar shows IPv4.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Menu") {
                Toggle(isOn: $showsLocationDetails) {
                    Text("Show city and provider")
                    Text("Sends your IP address to ipinfo.io.")
                }
                Toggle(isOn: $showsMap) {
                    Text("Show map")
                    Text("Loads a map of your IP location from Apple Maps. Hidden while the IP is hidden.")
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { launchAtLogin.refresh() }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin.isEnabled },
            set: { launchAtLogin.setEnabled($0) }
        )
    }
}
