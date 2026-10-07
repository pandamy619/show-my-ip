import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(SettingsKey.displayMode) private var displayMode: DisplayMode = .automatic
    @AppStorage(SettingsKey.compactStyle) private var compactStyle: CompactStyle = .flag
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
