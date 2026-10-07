import SwiftUI

struct PrivacySettingsView: View {
    typealias Key = PrivacyPreferences.Key

    private static let footer = """
        While hidden, the address in the menu bar is covered by the chosen style, and addresses in the menu \
        and notifications are masked, for example ***.**.**.**. Clicking an address in the menu still copies it.
        """

    @AppStorage(Key.allowsHiding) private var allowsHiding = false
    @AppStorage(Key.hidesOnLaunch) private var hidesOnLaunch = false
    @AppStorage(Key.hiddenStyle) private var hiddenStyle = HiddenStyle.animated

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $allowsHiding) {
                    Text("Allow hiding IP")
                    Text("Option-click the menu bar icon to hide or show your IP address.")
                }
                Toggle("Hide IP on launch", isOn: $hidesOnLaunch)
                    .disabled(!allowsHiding)
                Picker("Hidden IP style", selection: $hiddenStyle) {
                    ForEach(HiddenStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
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
