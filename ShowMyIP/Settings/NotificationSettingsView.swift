import AppKit
import SwiftUI

struct NotificationSettingsView: View {
    typealias Key = NotificationPreferences.Key

    private enum PermissionState {
        case idle
        case waiting
        case deniedByUser
        case deniedInSystemSettings
    }

    private static let initial = NotificationPreferences()

    let currentCountry: CountryCode?
    let coordinator: NotificationCoordinator

    @AppStorage(Key.isEnabled) private var isEnabled = Self.initial.isEnabled
    @AppStorage(Key.notifiesCountryChange) private var notifiesCountryChange = Self.initial.notifiesCountryChange
    @AppStorage(Key.notifiesAddressChange) private var notifiesAddressChange = Self.initial.notifiesAddressChange
    @AppStorage(Key.notifiesHomeCountry) private var notifiesHomeCountry = Self.initial.notifiesHomeCountry
    @AppStorage(Key.notifiesConnectionLoss) private var notifiesConnectionLoss = Self.initial.notifiesConnectionLoss
    @AppStorage(Key.notifiesIPv6Leak) private var notifiesIPv6Leak = Self.initial.notifiesIPv6Leak
    @AppStorage(Key.notifiesVPNDisconnect) private var notifiesVPNDisconnect = Self.initial.notifiesVPNDisconnect
    @AppStorage(Key.notifiesDNSLeak) private var notifiesDNSLeak = Self.initial.notifiesDNSLeak
    @AppStorage(Key.homeCountryCode) private var homeCountryCode = ""
    @State private var permissionState = PermissionState.idle

    private let countryOptions = CountryOptions.all(locale: .current)

    var body: some View {
        Form {
            Section {
                Toggle("Enable notifications", isOn: enabledBinding)
                permissionMessage
            }
            Section("Notify about") {
                Toggle("Country change", isOn: $notifiesCountryChange)
                Toggle("IP address change", isOn: $notifiesAddressChange)
                Toggle("Home country (VPN may be off)", isOn: $notifiesHomeCountry)
                Toggle("Connection loss", isOn: $notifiesConnectionLoss)
                Toggle("IPv6 leak (IPv6 in another country than IPv4)", isOn: $notifiesIPv6Leak)
                Toggle("VPN disconnected", isOn: $notifiesVPNDisconnect)
                Toggle("DNS leak (needs DNS check in General settings)", isOn: $notifiesDNSLeak)
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
        .task { await syncWithSystemPermission() }
    }

    @ViewBuilder
    private var permissionMessage: some View {
        switch permissionState {
        case .idle:
            EmptyView()
        case .waiting:
            Text("Waiting for permission — answer the macOS notification banner.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .deniedByUser:
            Text("Permission was not granted.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .deniedInSystemSettings:
            HStack {
                Text("Notifications are turned off for Show My IP in System Settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Open Notification Settings", action: openSystemNotificationSettings)
            }
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { isEnabled },
            set: { newValue in
                guard newValue else {
                    isEnabled = false
                    permissionState = .idle
                    return
                }
                isEnabled = true
                permissionState = .waiting
                Task { await enableNotifications() }
            }
        )
    }

    private func enableNotifications() async {
        switch await coordinator.enableNotifications() {
        case .enabled:
            permissionState = .idle
        case .deniedByUser:
            isEnabled = false
            permissionState = .deniedByUser
        case .deniedInSystemSettings:
            isEnabled = false
            permissionState = .deniedInSystemSettings
        }
    }

    private func syncWithSystemPermission() async {
        guard isEnabled, await coordinator.authorizationStatus() == .denied else {
            return
        }
        isEnabled = false
        permissionState = .deniedInSystemSettings
    }

    private func openSystemNotificationSettings() {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let address = "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleID)"
        if let url = URL(string: address) {
            NSWorkspace.shared.open(url)
        }
    }
}
