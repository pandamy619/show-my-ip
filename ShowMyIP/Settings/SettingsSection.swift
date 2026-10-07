import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case notifications
    case about

    var id: Self { self }

    var title: String {
        switch self {
        case .general:
            "General"
        case .notifications:
            "Notifications"
        case .about:
            "About"
        }
    }

    var symbolName: String {
        switch self {
        case .general:
            "gearshape.fill"
        case .notifications:
            "bell.badge.fill"
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
