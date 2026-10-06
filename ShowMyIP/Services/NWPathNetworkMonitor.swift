import Foundation
import Network

struct NWPathNetworkMonitor: NetworkMonitoring {
    func snapshots() -> AsyncStream<NetworkSnapshot> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                let interfaceNames = Set(path.availableInterfaces.map(\.name))
                continuation.yield(NetworkSnapshot(status: path.status, interfaceNames: interfaceNames))
            }
            continuation.onTermination = { _ in
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: "ShowMyIP.NetworkMonitor"))
        }
    }
}
