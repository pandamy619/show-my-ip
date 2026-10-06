import Network

struct NetworkSnapshot: Equatable, Sendable {
    let isConnected: Bool
    let interfaceNames: Set<String>

    init(isConnected: Bool, interfaceNames: Set<String>) {
        self.isConnected = isConnected
        self.interfaceNames = interfaceNames
    }

    init(status: NWPath.Status, interfaceNames: Set<String>) {
        self.init(isConnected: status == .satisfied, interfaceNames: interfaceNames)
    }
}

protocol NetworkMonitoring: Sendable {
    func snapshots() -> AsyncStream<NetworkSnapshot>
}
