struct NotificationDecider {
    private var lastInfo: IPInfo?
    private var isOffline = false
    private var wasVPNActive: Bool?

    mutating func process(
        _ status: AppState.Status,
        vpnActive: Bool? = nil,
        preferences: NotificationPreferences
    ) -> IPNotification? {
        let statusNotification = processStatus(status, preferences: preferences)
        return vpnDisconnected(vpnActive, preferences: preferences) ? .vpnDisconnected : statusNotification
    }

    private mutating func vpnDisconnected(_ vpnActive: Bool?, preferences: NotificationPreferences) -> Bool {
        guard let vpnActive else {
            return false
        }
        defer { wasVPNActive = vpnActive }
        return wasVPNActive == true && !vpnActive && preferences.isEnabled && preferences.notifiesVPNDisconnect
    }

    private mutating func processStatus(
        _ status: AppState.Status,
        preferences: NotificationPreferences
    ) -> IPNotification? {
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
            guard preferences.isEnabled else {
                return nil
            }
            if let leak = startedIPv6Leak(previous: lastInfo, current: info, preferences: preferences) {
                return leak
            }
            if let leak = startedDNSLeak(previous: lastInfo, current: info, preferences: preferences) {
                return leak
            }
            guard let previous = lastInfo else {
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
        if let home = arrivedHomeCountry(from: previous, to: current, preferences: preferences) {
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

    private func startedIPv6Leak(
        previous: IPInfo?,
        current: IPInfo,
        preferences: NotificationPreferences
    ) -> IPNotification? {
        guard
            preferences.notifiesIPv6Leak, let ipv4Country = current.country,
            let ipv6Country = current.leakedIPv6Country, previous?.leakedIPv6Country != ipv6Country
        else {
            return nil
        }
        return .ipv6Leak(ipv4Country: ipv4Country, ipv6Country: ipv6Country)
    }

    private func startedDNSLeak(
        previous: IPInfo?,
        current: IPInfo,
        preferences: NotificationPreferences
    ) -> IPNotification? {
        guard
            preferences.notifiesDNSLeak, let ipCountry = current.country,
            let dnsCountry = current.dnsLeakCountry, previous?.dnsLeakCountry != dnsCountry
        else {
            return nil
        }
        return .dnsLeak(ipCountry: ipCountry, dnsCountry: dnsCountry)
    }

    private func arrivedHomeCountry(
        from previous: IPInfo,
        to current: IPInfo,
        preferences: NotificationPreferences
    ) -> CountryCode? {
        guard preferences.notifiesHomeCountry, let home = preferences.homeCountry else {
            return nil
        }
        return current.country == home && previous.country != home ? home : nil
    }
}
