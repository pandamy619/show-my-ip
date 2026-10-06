import Network
import Testing

@testable import ShowMyIP

struct NetworkSnapshotTests {
    @Test func satisfiedPathIsConnected() {
        let snapshot = NetworkSnapshot(status: .satisfied, interfaceNames: ["en0"])
        #expect(snapshot.isConnected)
    }

    @Test func unsatisfiedPathIsDisconnected() {
        let snapshot = NetworkSnapshot(status: .unsatisfied, interfaceNames: [])
        #expect(!snapshot.isConnected)
    }

    @Test func pathRequiringConnectionIsDisconnected() {
        let snapshot = NetworkSnapshot(status: .requiresConnection, interfaceNames: ["en0"])
        #expect(!snapshot.isConnected)
    }

    @Test func vpnInterfaceAppearingChangesSnapshot() {
        let withoutVPN = NetworkSnapshot(status: .satisfied, interfaceNames: ["en0"])
        let withVPN = NetworkSnapshot(status: .satisfied, interfaceNames: ["en0", "utun4"])
        #expect(withoutVPN != withVPN)
    }

    @Test func interfaceOrderDoesNotMatter() {
        let first = NetworkSnapshot(isConnected: true, interfaceNames: ["en0", "utun4"])
        let second = NetworkSnapshot(isConnected: true, interfaceNames: ["utun4", "en0"])
        #expect(first == second)
    }
}
