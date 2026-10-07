import SwiftUI

struct SettingsView: View {
    let currentCountry: CountryCode?
    let notificationCoordinator: NotificationCoordinator

    @State private var selection: SettingsSection? = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Label {
                    Text(section.title)
                } icon: {
                    SettingsSectionIcon(section: section)
                }
                .tag(section)
            }
            .navigationSplitViewColumnWidth(190)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            detail(for: selection ?? .general)
                .navigationTitle((selection ?? .general).title)
        }
        .frame(width: 720, height: 480)
    }

    @ViewBuilder
    private func detail(for section: SettingsSection) -> some View {
        switch section {
        case .general:
            GeneralSettingsView()
        case .notifications:
            NotificationSettingsView(currentCountry: currentCountry, coordinator: notificationCoordinator)
        case .privacy:
            PrivacySettingsView()
        case .about:
            AboutSettingsView()
        }
    }
}
