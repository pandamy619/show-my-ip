@testable import ShowMyIP

struct StubNetworkMonitor: NetworkMonitoring {
    let stream: AsyncStream<NetworkSnapshot>

    func snapshots() -> AsyncStream<NetworkSnapshot> {
        stream
    }
}
