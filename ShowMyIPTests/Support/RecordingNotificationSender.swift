@testable import ShowMyIP

actor RecordingNotificationSender: NotificationSending {
    private(set) var sentContents: [NotificationContent] = []
    private(set) var authorizationRequestCount = 0
    private let status: NotificationAuthorization
    private let isAuthorizationGranted: Bool

    init(status: NotificationAuthorization = .notDetermined, isAuthorizationGranted: Bool = true) {
        self.status = status
        self.isAuthorizationGranted = isAuthorizationGranted
    }

    func authorizationStatus() async -> NotificationAuthorization {
        status
    }

    func requestAuthorization() async -> Bool {
        authorizationRequestCount += 1
        return isAuthorizationGranted
    }

    func send(_ content: NotificationContent) async {
        sentContents.append(content)
    }
}
