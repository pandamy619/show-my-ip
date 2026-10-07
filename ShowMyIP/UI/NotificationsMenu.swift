import SwiftUI

struct NotificationsMenu: View {
    typealias Key = NotificationPreferences.Key

    private static let initial = NotificationPreferences()

    let currentCountry: CountryCode?
    let requestAuthorization: @MainActor () async -> Bool

    @AppStorage(Key.isEnabled) private var isEnabled = Self.initial.isEnabled
    @AppStorage(Key.notifiesCountryChange) private var notifiesCountryChange = Self.initial.notifiesCountryChange
    @AppStorage(Key.notifiesAddressChange) private var notifiesAddressChange = Self.initial.notifiesAddressChange
    @AppStorage(Key.notifiesHomeCountry) private var notifiesHomeCountry = Self.initial.notifiesHomeCountry
    @AppStorage(Key.notifiesConnectionLoss) private var notifiesConnectionLoss = Self.initial.notifiesConnectionLoss
    @AppStorage(Key.homeCountryCode) private var homeCountryCode = ""

    var body: some View {
        Menu("Notifications") {
            Toggle("Enabled", isOn: enabledBinding)
            Divider()
            Toggle("Country Change", isOn: $notifiesCountryChange)
            Toggle("IP Address Change", isOn: $notifiesAddressChange)
            Toggle("Home Country Alert", isOn: $notifiesHomeCountry)
            Toggle("Connection Loss", isOn: $notifiesConnectionLoss)
            Divider()
            Text("Home Country: \(homeCountryTitle)")
            if let currentCountry {
                Button("Set \(currentCountry.flagEmoji) \(currentCountry.value) as Home Country") {
                    homeCountryCode = currentCountry.value
                }
            }
            if !homeCountryCode.isEmpty {
                Button("Clear Home Country") {
                    homeCountryCode = ""
                }
            }
        }
    }

    private var homeCountryTitle: String {
        guard let country = CountryCode(homeCountryCode) else {
            return "Not set"
        }
        return "\(country.flagEmoji) \(country.value)"
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { isEnabled },
            set: { newValue in
                guard newValue else {
                    isEnabled = false
                    return
                }
                Task { @MainActor in
                    isEnabled = await requestAuthorization()
                }
            }
        )
    }
}
