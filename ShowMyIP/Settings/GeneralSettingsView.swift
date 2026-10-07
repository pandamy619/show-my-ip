import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(SettingsKey.displayMode) private var displayMode: DisplayMode = .automatic
    @AppStorage(SettingsKey.compactStyle) private var compactStyle: CompactStyle = .flag

    var body: some View {
        Form {
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
        .formStyle(.grouped)
    }
}
