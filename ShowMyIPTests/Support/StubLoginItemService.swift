@testable import ShowMyIP

struct LoginItemFailure: Error {}

@MainActor
final class StubLoginItemService: LoginItemService {
    var status: LoginItemStatus
    var statusAfterRegister: LoginItemStatus = .enabled
    var failure: LoginItemFailure?
    private(set) var registerCallCount = 0
    private(set) var unregisterCallCount = 0

    init(status: LoginItemStatus = .disabled) {
        self.status = status
    }

    func register() throws {
        registerCallCount += 1
        if let failure {
            throw failure
        }
        status = statusAfterRegister
    }

    func unregister() throws {
        unregisterCallCount += 1
        if let failure {
            throw failure
        }
        status = .disabled
    }
}
