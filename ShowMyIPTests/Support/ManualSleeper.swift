actor ManualSleeper {
    private var waiters: [CheckedContinuation<Void, Never>] = []

    var pendingCount: Int {
        waiters.count
    }

    func sleep(for duration: Duration) async throws {
        await withCheckedContinuation { waiters.append($0) }
        try Task.checkCancellation()
    }

    func advance() {
        let resumed = waiters
        waiters.removeAll()
        resumed.forEach { $0.resume() }
    }
}
