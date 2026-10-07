import Observation

@MainActor
@Observable
final class LaunchAtLoginController {
    private(set) var status: LoginItemStatus
    private(set) var didFail = false

    @ObservationIgnored private let service: any LoginItemService

    init(service: any LoginItemService) {
        self.service = service
        status = service.status
    }

    var isEnabled: Bool {
        status != .disabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
            didFail = false
        } catch {
            didFail = true
        }
        status = service.status
    }

    func refresh() {
        status = service.status
    }
}
