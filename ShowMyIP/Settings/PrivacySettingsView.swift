import SwiftUI

struct PrivacySettingsView: View {
    typealias Key = PrivacyPreferences.Key

    private static let footer = """
        While hidden, addresses in the menu bar, the menu and notifications are masked, for example ***.**.**.**. \
        Clicking an address in the menu still copies it.
        """

    @AppStorage(Key.allowsHiding) private var allowsHiding = false
    @AppStorage(Key.hidesOnLaunch) private var hidesOnLaunch = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $allowsHiding) {
                    Text("Allow hiding IP")
                    Text("Option-click the menu bar icon to hide or show your IP address.")
                }
                Toggle("Hide IP on launch", isOn: $hidesOnLaunch)
                    .disabled(!allowsHiding)
            } footer: {
                Text(Self.footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
