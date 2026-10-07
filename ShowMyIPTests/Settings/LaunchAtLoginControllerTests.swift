import Testing

@testable import ShowMyIP

@MainActor
struct LaunchAtLoginControllerTests {
    @Test(arguments: [LoginItemStatus.enabled, .disabled, .requiresApproval])
    func initialStatusComesFromService(status: LoginItemStatus) {
        let controller = LaunchAtLoginController(service: StubLoginItemService(status: status))
        #expect(controller.status == status)
    }

    @Test func enablingRegistersLoginItem() {
        let service = StubLoginItemService()
        let controller = LaunchAtLoginController(service: service)
        controller.setEnabled(true)
        #expect(service.registerCallCount == 1)
        #expect(controller.isEnabled)
        #expect(!controller.didFail)
    }

    @Test func disablingUnregistersLoginItem() {
        let service = StubLoginItemService(status: .enabled)
        let controller = LaunchAtLoginController(service: service)
        controller.setEnabled(false)
        #expect(service.unregisterCallCount == 1)
        #expect(!controller.isEnabled)
    }

    @Test func failureKeepsPreviousStatus() {
        let service = StubLoginItemService()
        service.failure = LoginItemFailure()
        let controller = LaunchAtLoginController(service: service)
        controller.setEnabled(true)
        #expect(controller.status == .disabled)
        #expect(controller.didFail)
    }

    @Test func successClearsPreviousFailure() {
        let service = StubLoginItemService()
        service.failure = LoginItemFailure()
        let controller = LaunchAtLoginController(service: service)
        controller.setEnabled(true)
        service.failure = nil
        controller.setEnabled(true)
        #expect(!controller.didFail)
    }

    @Test func pendingApprovalCountsAsEnabled() {
        let service = StubLoginItemService()
        service.statusAfterRegister = .requiresApproval
        let controller = LaunchAtLoginController(service: service)
        controller.setEnabled(true)
        #expect(controller.status == .requiresApproval)
        #expect(controller.isEnabled)
    }

    @Test func refreshPicksUpExternalChanges() {
        let service = StubLoginItemService(status: .enabled)
        let controller = LaunchAtLoginController(service: service)
        service.status = .disabled
        controller.refresh()
        #expect(controller.status == .disabled)
    }
}
