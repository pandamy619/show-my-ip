import SwiftUI

struct PrivacySettingsView: View {
    typealias Key = PrivacyPreferences.Key

    private static let footer = String(
        localized: """
            While hidden, addresses in the menu bar and menu are covered by the chosen style, \
            and notifications don't show them. Clicking an address in the menu still copies it.
            """
    )

    @AppStorage(Key.allowsHiding) private var allowsHiding = false
    @AppStorage(Key.hidesOnLaunch) private var hidesOnLaunch = false
    @AppStorage(Key.hiddenStyle) private var hiddenStyle = HiddenStyle.animated
    @AppStorage(SettingsKey.keepsHistory) private var keepsHistory = true

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
            Section {
                Toggle(isOn: $keepsHistory) {
                    Text("Keep IP history")
                    Text("Stores up to 50 recent addresses on this Mac. Turning it off erases the history.")
                }
            }
        }
        .formStyle(.grouped)
    }
}
