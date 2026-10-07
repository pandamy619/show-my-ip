import Foundation

enum NotificationContentBuilder {
    private static let unknownCountry = "🌐 Unknown"

    static func content(
        for notification: IPNotification,
        locale: Locale,
        isHidden: Bool = false
    ) -> NotificationContent {
        switch notification {
        case .countryChanged(let from, let to):
            NotificationContent(
                title: "Country changed",
                body: "\(countryName(from, locale: locale)) → \(countryName(to, locale: locale))"
            )
        case .addressChanged(let from, let to):
            NotificationContent(
                title: "IP address changed",
                body: isHidden ? "Your public IP address has changed." : "\(from.value) → \(to.value)"
            )
        case .homeCountryDetected(let country):
            NotificationContent(
                title: "VPN may be off",
                body: "You are online from \(countryName(country, locale: locale))",
                playsSound: true
            )
        case .connectionLost:
            NotificationContent(title: "Connection lost", body: "No network connection")
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
