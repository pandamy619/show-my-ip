import Testing

@testable import ShowMyIP

@MainActor
struct AppStateTests {
    private let wifi = NetworkSnapshot(isConnected: true, interfaceNames: ["en0"])
    private let wifiWithVPN = NetworkSnapshot(isConnected: true, interfaceNames: ["en0", "utun4"])
    private let wifiWithOtherVPN = NetworkSnapshot(isConnected: true, interfaceNames: ["en0", "utun5"])
    private let offline = NetworkSnapshot(isConnected: false, interfaceNames: [])

    private func makeState(
        provider: any IPProvider,
        networkMonitor: any NetworkMonitoring = StubNetworkMonitor(stream: AsyncStream { _ in }),
        sleeper: ManualSleeper = ManualSleeper(),
        localAddresses: [LocalAddress] = [],
        vpnStatus: VPNStatus = VPNStatus(interfaceName: nil)
    ) -> AppState {
        AppState(
            provider: provider,
            networkMonitor: networkMonitor,
            sleep: { duration in try await sleeper.sleep(for: duration) },
            readLocalAddresses: { localAddresses },
            readVPNStatus: { vpnStatus }
        )
    }

    @Test func initialStatusIsLoading() throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        let state = makeState(provider: StubIPProvider { info })
        #expect(state.status == .loading)
    }

    @Test func refreshLoadsInfo() async throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let state = makeState(provider: StubIPProvider { info })
        await state.refresh()
        #expect(state.status == .loaded(info))
    }

    @Test func refreshFailureIsReported() async {
        let state = makeState(provider: StubIPProvider { () throws(IPProviderError) -> IPInfo in throw .network })
        await state.refresh()
        #expect(state.status == .failed(.network))
    }

    @Test func disconnectSetsOfflineWithoutFetching() {
        let state = makeState(
            provider: StubIPProvider { () throws(IPProviderError) -> IPInfo in
                Issue.record("Provider must not be called while offline")
                throw .network
            }
        )
        state.networkDidChange(wifi)
        state.networkDidChange(offline)
        #expect(state.status == .offline)
    }

    @Test func refreshWhileOfflineKeepsOffline() async {
        let state = makeState(
            provider: StubIPProvider { () throws(IPProviderError) -> IPInfo in
                Issue.record("Provider must not be called while offline")
                throw .network
            }
        )
        state.networkDidChange(offline)
        await state.refresh()
        #expect(state.status == .offline)
    }

    @Test func reconnectRefreshesAfterDebounce() async throws {
        let info = try IPInfo.fixture(address: "8.8.8.8", country: "US")
        let sleeper = ManualSleeper()
        let state = makeState(provider: StubIPProvider { info }, sleeper: sleeper)

        state.networkDidChange(offline)
        state.networkDidChange(wifi)
        try await waitUntil { await sleeper.pendingCount == 1 }
        #expect(state.status == .offline)

        await sleeper.advance()
        try await waitUntil { await state.status == .loaded(info) }
    }

    @Test func rapidChangesRefreshOnce() async throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        let counter = CallCounter()
        let sleeper = ManualSleeper()
        let state = makeState(
            provider: StubIPProvider {
                await counter.increment()
                return info
            },
            sleeper: sleeper
        )

        state.networkDidChange(wifi)
        state.networkDidChange(wifiWithVPN)
        state.networkDidChange(wifiWithOtherVPN)
        try await waitUntil { await sleeper.pendingCount == 2 }

        await sleeper.advance()
        try await waitUntil { await state.status == .loaded(info) }
        #expect(await counter.count == 1)
    }

    @Test func duplicateSnapshotIsIgnored() async throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        let sleeper = ManualSleeper()
        let state = makeState(provider: StubIPProvider { info }, sleeper: sleeper)

        state.networkDidChange(wifi)
        state.networkDidChange(wifi)
        try await Task.sleep(for: .milliseconds(20))
        #expect(await sleeper.pendingCount == 0)
    }

    @Test func startLoadsInfoImmediately() async throws {
        let info = try IPInfo.fixture(address: "8.8.8.8", country: "DE")
        let state = makeState(provider: StubIPProvider { info })
        state.start()
        defer { state.stop() }
        try await waitUntil { await state.status == .loaded(info) }
    }

    @Test func startReactsToNetworkChanges() async throws {
        let (stream, continuation) = AsyncStream.makeStream(of: NetworkSnapshot.self)
        let info = try IPInfo.fixture(address: "8.8.8.8")
        let state = makeState(provider: StubIPProvider { info }, networkMonitor: StubNetworkMonitor(stream: stream))
        state.start()
        defer { state.stop() }

        continuation.yield(wifi)
        continuation.yield(offline)
        try await waitUntil { await state.status == .offline }
    }

    @Test func refreshUpdatesLocalAddresses() async throws {
        let info = try IPInfo.fixture(address: "8.8.8.8")
        let address = try #require(IPAddress("192.168.1.5"))
        let local = LocalAddress(interfaceName: "en0", address: address)
        let state = makeState(provider: StubIPProvider { info }, localAddresses: [local])
        await state.refresh()
        #expect(state.localAddresses == [local])
    }

    @Test func refreshReadsVPNStatus() async throws {
        let info = try IPInfo.fixture(address: "185.23.45.67", country: "NL")
        let state = makeState(provider: StubIPProvider { info }, vpnStatus: VPNStatus(interfaceName: "utun4"))
        await state.refresh()
        #expect(state.vpnStatus == VPNStatus(interfaceName: "utun4"))
    }
}
