import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case notifications
    case privacy
    case about

    var id: Self { self }

    var title: String {
        switch self {
        case .general:
            String(localized: "General")
        case .notifications:
            String(localized: "Notifications")
        case .privacy:
            String(localized: "Privacy")
        case .about:
            String(localized: "About")
        }
    }

    var symbolName: String {
        switch self {
        case .general:
            "gearshape.fill"
        case .notifications:
            "bell.badge.fill"
        case .privacy:
            "eye.slash.fill"
        case .about:
            "info"
        }
    }

    var tint: Color {
        switch self {
        case .general:
            .gray
        case .notifications:
            .red
        case .privacy:
            .green
        case .about:
            .blue
        }
    }
}

struct SettingsSectionIcon: View {
    let section: SettingsSection

    var body: some View {
        Image(systemName: section.symbolName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(section.tint.gradient, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
