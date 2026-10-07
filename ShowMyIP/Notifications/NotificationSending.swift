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

protocol NotificationSending: Sendable {
    func requestAuthorization() async -> Bool
    func send(_ content: NotificationContent) async
}
