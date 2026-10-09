import Observation

@MainActor
@Observable
final class AppState {
    enum Status: Equatable, Sendable {
        case loading
        case loaded(IPInfo)
        case offline
        case failed(IPProviderError)
    }

    typealias Sleep = @Sendable (Duration) async throws -> Void

    private(set) var status: Status = .loading
    private(set) var localAddresses: [LocalAddress] = []
    private(set) var vpnStatus = VPNStatus(interfaceName: nil)

    private let provider: any IPProvider
    private let networkMonitor: any NetworkMonitoring
    private let refreshInterval: Duration
    private let debounceInterval: Duration
    private let sleep: Sleep
    private let readLocalAddresses: @Sendable () -> [LocalAddress]
    private let readVPNStatus: @Sendable () -> VPNStatus

    @ObservationIgnored private var lastSnapshot: NetworkSnapshot?
    @ObservationIgnored private var refreshGeneration = 0
    @ObservationIgnored private var debouncedRefreshTask: Task<Void, Never>?
    @ObservationIgnored private var backgroundTasks: [Task<Void, Never>] = []

    init(
        provider: any IPProvider,
        networkMonitor: any NetworkMonitoring,
        refreshInterval: Duration = .seconds(300),
        debounceInterval: Duration = .seconds(3),
        sleep: @escaping Sleep = { try await Task.sleep(for: $0) },
        readLocalAddresses: @escaping @Sendable () -> [LocalAddress] = LocalAddressReader.read,
        readVPNStatus: @escaping @Sendable () -> VPNStatus = LocalAddressReader.vpnStatus
    ) {
        self.provider = provider
        self.networkMonitor = networkMonitor
        self.refreshInterval = refreshInterval
        self.debounceInterval = debounceInterval
        self.sleep = sleep
        self.readLocalAddresses = readLocalAddresses
        self.readVPNStatus = readVPNStatus
    }

    func start() {
        guard backgroundTasks.isEmpty else {
            return
        }
        let snapshots = networkMonitor.snapshots()
        backgroundTasks = [
            Task { [weak self] in
                await self?.refresh()
            },
            Task { [weak self] in
                for await snapshot in snapshots {
                    self?.networkDidChange(snapshot)
                }
            },
            Task { [weak self] in
                await self?.runPeriodicRefresh()
            },
        ]
    }

    func stop() {
        backgroundTasks.forEach { $0.cancel() }
        backgroundTasks.removeAll()
        debouncedRefreshTask?.cancel()
        debouncedRefreshTask = nil
    }

    func refresh() async {
        readInterfaces()
        guard !isOffline else {
            status = .offline
            return
        }
        refreshGeneration += 1
        let generation = refreshGeneration
        let newStatus: Status
        AppLogger.ipLookup.debug("Refreshing public IP")
        do {
            let info = try await provider.fetchIPInfo()
            let country = info.country?.value ?? "unknown"
            AppLogger.ipLookup.info(
                "Public IP \(info.address.value, privacy: .private), country \(country, privacy: .public)"
            )
            newStatus = .loaded(info)
        } catch {
            AppLogger.ipLookup.error("Public IP lookup failed: \(String(describing: error), privacy: .public)")
            newStatus = .failed(error)
        }
        guard generation == refreshGeneration, !isOffline else {
            return
        }
        status = newStatus
    }

    func networkDidChange(_ snapshot: NetworkSnapshot) {
        let previous = lastSnapshot
        lastSnapshot = snapshot
        guard snapshot != previous else {
            return
        }
        let interfaces = snapshot.interfaceNames.sorted().joined(separator: ", ")
        AppLogger.network.info(
            "Network changed, connected: \(snapshot.isConnected), interfaces: \(interfaces, privacy: .public)"
        )
        guard snapshot.isConnected else {
            debouncedRefreshTask?.cancel()
            readInterfaces()
            status = .offline
            return
        }
        guard previous != nil else {
            return
        }
        scheduleDebouncedRefresh()
    }

    private func readInterfaces() {
        localAddresses = readLocalAddresses()
        vpnStatus = readVPNStatus()
    }

    private var isOffline: Bool {
        lastSnapshot?.isConnected == false
    }

    private func scheduleDebouncedRefresh() {
        debouncedRefreshTask?.cancel()
        let sleep = sleep
        let debounceInterval = debounceInterval
        debouncedRefreshTask = Task { [weak self] in
            do {
                try await sleep(debounceInterval)
            } catch {
                return
            }
            await self?.refresh()
        }
    }

    private func runPeriodicRefresh() async {
        while !Task.isCancelled {
            do {
                try await sleep(refreshInterval)
            } catch {
                return
            }
            await refresh()
        }
    }
}
