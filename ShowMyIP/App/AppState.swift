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

    private let provider: any IPProvider
    private let networkMonitor: any NetworkMonitoring
    private let refreshInterval: Duration
    private let debounceInterval: Duration
    private let sleep: Sleep

    @ObservationIgnored private var lastSnapshot: NetworkSnapshot?
    @ObservationIgnored private var refreshGeneration = 0
    @ObservationIgnored private var debouncedRefreshTask: Task<Void, Never>?
    @ObservationIgnored private var backgroundTasks: [Task<Void, Never>] = []

    init(
        provider: any IPProvider,
        networkMonitor: any NetworkMonitoring,
        refreshInterval: Duration = .seconds(300),
        debounceInterval: Duration = .seconds(3),
        sleep: @escaping Sleep = { try await Task.sleep(for: $0) }
    ) {
        self.provider = provider
        self.networkMonitor = networkMonitor
        self.refreshInterval = refreshInterval
        self.debounceInterval = debounceInterval
        self.sleep = sleep
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
        guard !isOffline else {
            status = .offline
            return
        }
        refreshGeneration += 1
        let generation = refreshGeneration
        let newStatus: Status
        do {
            let info = try await provider.fetchIPInfo()
            newStatus = .loaded(info)
        } catch {
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
        guard snapshot.isConnected else {
            debouncedRefreshTask?.cancel()
            status = .offline
            return
        }
        guard previous != nil else {
            return
        }
        scheduleDebouncedRefresh()
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
