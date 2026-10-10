import AppIntents

struct GetPublicIPIntent: AppIntent {
    static var title: LocalizedStringResource { "Get Public IP" }
    static var description: IntentDescription { IntentDescription("Returns your current public IP address.") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        .result(value: try await AppServices.currentInfo().address.value)
    }
}

struct GetIPDetailsIntent: AppIntent {
    static var title: LocalizedStringResource { "Get IP Details" }
    static var description: IntentDescription {
        IntentDescription("Returns your public IP, IPv6, country, city, provider and VPN status as JSON.")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let info = try await AppServices.currentInfo()
        return .result(value: IPInfoJSON.encode(info, vpnStatus: AppServices.appState?.vpnStatus))
    }
}

struct SetIPHiddenIntent: AppIntent {
    static var title: LocalizedStringResource { "Hide or Show IP" }
    static var description: IntentDescription { IntentDescription("Hides or shows your IP address in Show My IP.") }

    @Parameter(title: "Hidden")
    var isHidden: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        guard AppServices.privacyState?.setHidden(isHidden) == true else {
            throw ShortcutError.hidingNotAllowed
        }
        return .result()
    }
}

struct ToggleIPHiddenIntent: AppIntent {
    static var title: LocalizedStringResource { "Toggle IP Hiding" }
    static var description: IntentDescription {
        IntentDescription("Hides your IP address if it is shown, and shows it if it is hidden.")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let privacyState = AppServices.privacyState, privacyState.setHidden(!privacyState.isHidden) else {
            throw ShortcutError.hidingNotAllowed
        }
        return .result()
    }
}

struct ShowMyIPShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetPublicIPIntent(),
            phrases: ["Get my IP with \(.applicationName)"],
            shortTitle: "Public IP",
            systemImageName: "globe"
        )
        AppShortcut(
            intent: ToggleIPHiddenIntent(),
            phrases: ["Toggle IP hiding in \(.applicationName)"],
            shortTitle: "Toggle IP Hiding",
            systemImageName: "eye.slash"
        )
    }
}
