import Foundation

@MainActor
final class NotificationCoordinator {
    private let sender: any NotificationSending
    private let locale: Locale
    private var decider = NotificationDecider()

    init(sender: any NotificationSending, locale: Locale = .current) {
        self.sender = sender
        self.locale = locale
    }

    func handle(_ status: AppState.Status, preferences: NotificationPreferences) {
        guard let notification = decider.process(status, preferences: preferences) else {
            return
        }
        let content = NotificationContentBuilder.content(for: notification, locale: locale)
        let sender = sender
        Task {
            await sender.send(content)
        }
    }

    func requestAuthorization() async -> Bool {
        await sender.requestAuthorization()
    }
}
