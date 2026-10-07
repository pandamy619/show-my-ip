import Foundation
import Testing

@testable import ShowMyIP

@MainActor
struct NotificationCoordinatorTests {
    private let enabled = NotificationPreferences(isEnabled: true)

    private func loaded(_ address: String, _ country: String) throws -> AppState.Status {
        .loaded(try IPInfo.fixture(address: address, country: country))
    }

    @Test func sendsNotificationForCountryChange() async throws {
        let sender = RecordingNotificationSender()
        let coordinator = NotificationCoordinator(sender: sender, locale: Locale(identifier: "en_US"))

        coordinator.handle(try loaded("1.1.1.1", "NL"), preferences: enabled)
        coordinator.handle(try loaded("2.2.2.2", "DE"), preferences: enabled)

        try await waitUntil { await sender.sentContents.count == 1 }
        #expect(await sender.sentContents.first?.title == "Country changed")
    }

    @Test func sendsNothingWhenDisabled() async throws {
        let sender = RecordingNotificationSender()
        let coordinator = NotificationCoordinator(sender: sender, locale: Locale(identifier: "en_US"))
        let disabled = NotificationPreferences()

        coordinator.handle(try loaded("1.1.1.1", "NL"), preferences: disabled)
        coordinator.handle(try loaded("2.2.2.2", "DE"), preferences: disabled)

        try await Task.sleep(for: .milliseconds(20))
        #expect(await sender.sentContents.isEmpty)
    }

    @Test func alreadyAuthorizedEnablesWithoutPrompt() async {
        let sender = RecordingNotificationSender(status: .authorized)
        let coordinator = NotificationCoordinator(sender: sender)
        #expect(await coordinator.enableNotifications() == .enabled)
        #expect(await sender.authorizationRequestCount == 0)
    }

    @Test func undecidedPromptsAndEnablesWhenGranted() async {
        let sender = RecordingNotificationSender(status: .notDetermined, isAuthorizationGranted: true)
        let coordinator = NotificationCoordinator(sender: sender)
        #expect(await coordinator.enableNotifications() == .enabled)
        #expect(await sender.authorizationRequestCount == 1)
    }

    @Test func undecidedPromptsAndReportsRefusal() async {
        let sender = RecordingNotificationSender(status: .notDetermined, isAuthorizationGranted: false)
        let coordinator = NotificationCoordinator(sender: sender)
        #expect(await coordinator.enableNotifications() == .deniedByUser)
    }

    @Test func deniedInSystemSettingsDoesNotPrompt() async {
        let sender = RecordingNotificationSender(status: .denied)
        let coordinator = NotificationCoordinator(sender: sender)
        #expect(await coordinator.enableNotifications() == .deniedInSystemSettings)
        #expect(await sender.authorizationRequestCount == 0)
    }

    @Test(arguments: [NotificationAuthorization.authorized, .denied, .notDetermined])
    func authorizationStatusIsPassedThrough(status: NotificationAuthorization) async {
        let coordinator = NotificationCoordinator(sender: RecordingNotificationSender(status: status))
        #expect(await coordinator.authorizationStatus() == status)
    }
}
