struct NotificationContent: Equatable, Sendable {
    let title: String
    let body: String
    let playsSound: Bool

    init(title: String, body: String, playsSound: Bool = false) {
        self.title = title
        self.body = body
        self.playsSound = playsSound
    }
}

enum NotificationAuthorization: Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
}

enum NotificationEnableResult: Equatable, Sendable {
    case enabled
    case deniedByUser
    case deniedInSystemSettings
}

protocol NotificationSending: Sendable {
    func authorizationStatus() async -> NotificationAuthorization
    func requestAuthorization() async -> Bool
    func send(_ content: NotificationContent) async
}
