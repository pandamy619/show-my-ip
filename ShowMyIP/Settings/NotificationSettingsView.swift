import SwiftUI

struct NotificationSettingsView: View {
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

    private let countryOptions = CountryOptions.all(locale: .current)

    var body: some View {
        Form {
            Section {
                Toggle("Enable notifications", isOn: enabledBinding)
            }
            Section("Notify about") {
                Toggle("Country change", isOn: $notifiesCountryChange)
                Toggle("IP address change", isOn: $notifiesAddressChange)
                Toggle("Home country (VPN may be off)", isOn: $notifiesHomeCountry)
                Toggle("Connection loss", isOn: $notifiesConnectionLoss)
            }
            .disabled(!isEnabled)
            Section("Home country") {
                Picker("Home country", selection: $homeCountryCode) {
                    Text("Not set").tag("")
                    ForEach(countryOptions) { option in
                        Text(option.title).tag(option.id)
                    }
                }
                if let currentCountry, currentCountry.value != homeCountryCode {
                    Button("Use current country (\(currentCountry.flagEmoji) \(currentCountry.value))") {
                        homeCountryCode = currentCountry.value
                    }
                }
                Text("Turn off your VPN and pick the country you are physically in.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .disabled(!isEnabled)
        }
        .formStyle(.grouped)
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
