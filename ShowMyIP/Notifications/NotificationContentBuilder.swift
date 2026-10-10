import Foundation

enum NotificationContentBuilder {
    private static var unknownCountry: String { "🌐 " + String(localized: "Unknown") }

    static func content(
        for notification: IPNotification,
        locale: Locale,
        isHidden: Bool = false
    ) -> NotificationContent {
        switch notification {
        case .countryChanged(let from, let to):
            NotificationContent(
                title: String(localized: "Country changed"),
                body: "\(countryName(from, locale: locale)) → \(countryName(to, locale: locale))"
            )
        case .addressChanged(let from, let to):
            NotificationContent(
                title: String(localized: "IP address changed"),
                body: isHidden
                    ? String(localized: "Your public IP address has changed.")
                    : "\(from.value) → \(to.value)"
            )
        case .homeCountryDetected(let country):
            NotificationContent(
                title: String(localized: "VPN may be off"),
                body: String(localized: "You are online from \(countryName(country, locale: locale))"),
                playsSound: true
            )
        case .ipv6Leak(let ipv4Country, let ipv6Country):
            ipv6LeakContent(
                ipv4: countryName(ipv4Country, locale: locale),
                ipv6: countryName(ipv6Country, locale: locale)
            )
        case .dnsLeak(let ipCountry, let dnsCountry):
            dnsLeakContent(ip: countryName(ipCountry, locale: locale), dns: countryName(dnsCountry, locale: locale))
        case .vpnDisconnected:
            NotificationContent(
                title: String(localized: "VPN disconnected"),
                body: String(localized: "Traffic now goes through your regular connection."),
                playsSound: true
            )
        case .connectionLost:
            NotificationContent(
                title: String(localized: "Connection lost"),
                body: String(localized: "No network connection")
            )
        }
    }

    private static func ipv6LeakContent(ipv4: String, ipv6: String) -> NotificationContent {
        NotificationContent(
            title: String(localized: "Possible IPv6 leak"),
            body: String(localized: "IPv6 goes through \(ipv6), IPv4 through \(ipv4)."),
            playsSound: true
        )
    }

    private static func dnsLeakContent(ip: String, dns: String) -> NotificationContent {
        NotificationContent(
            title: String(localized: "Possible DNS leak"),
            body: String(localized: "DNS queries go through \(dns), traffic through \(ip)."),
            playsSound: true
        )
    }

    private static func countryName(_ country: CountryCode?, locale: Locale) -> String {
        guard let country else {
            return unknownCountry
        }
        let name = locale.localizedString(forRegionCode: country.value) ?? country.value
        return "\(country.flagEmoji) \(name)"
    }
}
