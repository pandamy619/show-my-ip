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
        case .connectionLost:
            NotificationContent(
                title: String(localized: "Connection lost"),
                body: String(localized: "No network connection")
            )
        }
    }

    private static func countryName(_ country: CountryCode?, locale: Locale) -> String {
        guard let country else {
            return unknownCountry
        }
        let name = locale.localizedString(forRegionCode: country.value) ?? country.value
        return "\(country.flagEmoji) \(name)"
    }
}
