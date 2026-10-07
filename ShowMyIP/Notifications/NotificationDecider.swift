struct NotificationDecider {
    private var lastInfo: IPInfo?
    private var isOffline = false

    mutating func process(_ status: AppState.Status, preferences: NotificationPreferences) -> IPNotification? {
        switch status {
        case .loading, .failed:
            return nil
        case .offline:
            defer { isOffline = true }
            guard !isOffline, lastInfo != nil, preferences.isEnabled, preferences.notifiesConnectionLoss else {
                return nil
            }
            return .connectionLost
        case .loaded(let info):
            defer {
                lastInfo = info
                isOffline = false
            }
            guard let previous = lastInfo, preferences.isEnabled else {
                return nil
            }
            return notification(from: previous, to: info, preferences: preferences)
        }
    }

    private func notification(
        from previous: IPInfo,
        to current: IPInfo,
        preferences: NotificationPreferences
    ) -> IPNotification? {
        if preferences.notifiesHomeCountry, let home = preferences.homeCountry,
            current.country == home, previous.country != home
        {
            return .homeCountryDetected(home)
        }
        if preferences.notifiesCountryChange, previous.country != current.country {
            return .countryChanged(from: previous.country, to: current.country)
        }
        if preferences.notifiesAddressChange, previous.address != current.address {
            return .addressChanged(from: previous.address, to: current.address)
        }
        return nil
    }
}
