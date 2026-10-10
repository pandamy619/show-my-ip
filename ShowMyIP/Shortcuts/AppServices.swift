@MainActor
enum AppServices {
    static var appState: AppState?
    static var privacyState: PrivacyState?

    static func currentInfo() async throws(ShortcutError) -> IPInfo {
        guard let appState else {
            throw .unavailable
        }
        if case .loaded(let info) = appState.status {
            return info
        }
        await appState.refresh()
        guard case .loaded(let info) = appState.status else {
            throw .unavailable
        }
        return info
    }
}
