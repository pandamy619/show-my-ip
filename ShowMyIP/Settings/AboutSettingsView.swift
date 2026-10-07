import AppKit
import SwiftUI

struct AboutSettingsView: View {
    private static let repositoryURL = URL(string: "https://github.com/pandamy619/show-my-ip")

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
            Text("Show My IP")
                .font(.title2.bold())
            Text("Version \(version)")
                .foregroundStyle(.secondary)
            if let url = Self.repositoryURL {
                Link("GitHub", destination: url)
            }
            Text("MIT License")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
