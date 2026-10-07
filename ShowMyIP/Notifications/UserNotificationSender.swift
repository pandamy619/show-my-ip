import Foundation
import UserNotifications

final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate, Sendable {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

struct UserNotificationSender: NotificationSending {
    private let presenter = ForegroundNotificationPresenter()

    init() {
        UNUserNotificationCenter.current().delegate = presenter
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func send(_ content: NotificationContent) async {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = content.title
        notificationContent.body = content.body
        if content.playsSound {
            notificationContent.sound = .default
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
