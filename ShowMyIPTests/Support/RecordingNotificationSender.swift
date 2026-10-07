@testable import ShowMyIP

actor RecordingNotificationSender: NotificationSending {
    private(set) var sentContents: [NotificationContent] = []
    private let isAuthorizationGranted: Bool

    init(isAuthorizationGranted: Bool = true) {
        self.isAuthorizationGranted = isAuthorizationGranted
    }

    func requestAuthorization() async -> Bool {
        isAuthorizationGranted
    }

    func send(_ content: NotificationContent) async {
        sentContents.append(content)
    }
}
