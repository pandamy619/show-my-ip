import Foundation
import Network
import os

enum TCPLatencyProbe {
    private static let host = NWEndpoint.Host("1.1.1.1")
    private static let port = NWEndpoint.Port(integerLiteral: 443)
    private static let timeout: TimeInterval = 3
    private static let attempts = 3

    static func measure() async -> Duration? {
        var best: Duration?
        for _ in 0..<attempts {
            if let sample = await connectTime() {
                best = min(best ?? sample, sample)
            }
        }
        return best
    }

    private static func connectTime() async -> Duration? {
        await withCheckedContinuation { continuation in
            Attempt(continuation: continuation).start(host: host, port: port, timeout: timeout)
        }
    }

    private final class Attempt: @unchecked Sendable {
        private let continuation: CheckedContinuation<Duration?, Never>
        private let isFinished = OSAllocatedUnfairLock(initialState: false)
        private let clock = ContinuousClock()
        private let queue = DispatchQueue(label: "TCPLatencyProbe")
        private var connection: NWConnection?

        init(continuation: CheckedContinuation<Duration?, Never>) {
            self.continuation = continuation
        }

        func start(host: NWEndpoint.Host, port: NWEndpoint.Port, timeout: TimeInterval) {
            let connection = NWConnection(host: host, port: port, using: .tcp)
            let started = clock.now
            queue.sync { self.connection = connection }
            connection.stateUpdateHandler = { [self] state in
                switch state {
                case .ready:
                    finish(clock.now - started)
                case .failed, .waiting, .cancelled:
                    finish(nil)
                default:
                    break
                }
            }
            connection.start(queue: queue)
            queue.asyncAfter(deadline: .now() + timeout) { [self] in
                finish(nil)
            }
        }

        private func finish(_ result: Duration?) {
            let isFirst = isFinished.withLock { finished in
                defer { finished = true }
                return !finished
            }
            guard isFirst else {
                return
            }
            connection?.cancel()
            continuation.resume(returning: result)
        }
    }
}
