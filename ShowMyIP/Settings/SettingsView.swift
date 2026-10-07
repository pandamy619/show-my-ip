import SwiftUI

struct SettingsView: View {
    let currentCountry: CountryCode?
    let requestAuthorization: @MainActor () async -> Bool

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            NotificationSettingsView(currentCountry: currentCountry, requestAuthorization: requestAuthorization)
                .tabItem { Label("Notifications", systemImage: "bell") }
        }
        .frame(width: 460)
    }
}
