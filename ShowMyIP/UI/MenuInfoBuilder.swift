import Foundation

struct MenuInfoItem: Equatable, Identifiable {
    let title: String
    let copyValue: String?
    let maskedSuffix: String?

    var id: String { title }

    var unmaskedPrefix: String {
        guard let maskedSuffix else {
            return title
        }
        return String(title.dropLast(maskedSuffix.count))
    }

    init(title: String, copyValue: String? = nil, maskedSuffix: String? = nil) {
        self.title = title
        self.copyValue = copyValue
        self.maskedSuffix = maskedSuffix
    }
}

enum MenuInfoBuilder {
    static func items(
        for status: AppState.Status,
        localAddresses: [LocalAddress],
        locale: Locale,
        isHidden: Bool = false
    ) -> [MenuInfoItem] {
        statusItems(for: status, locale: locale, isHidden: isHidden)
            + localAddresses.map { localAddressItem($0, isHidden: isHidden) }
    }

    private static func statusItems(for status: AppState.Status, locale: Locale, isHidden: Bool) -> [MenuInfoItem] {
        switch status {
        case .loading:
            [MenuInfoItem(title: String(localized: "Loading…"))]
        case .offline:
            [MenuInfoItem(title: String(localized: "No network connection"))]
        case .failed:
            [MenuInfoItem(title: String(localized: "Could not determine public IP"))]
        case .loaded(let info):
            loadedItems(for: info, locale: locale, isHidden: isHidden)
        }
    }

    private static func loadedItems(for info: IPInfo, locale: Locale, isHidden: Bool) -> [MenuInfoItem] {
        var items: [MenuInfoItem] = []
        if let country = info.country {
            let name = locale.localizedString(forRegionCode: country.value) ?? country.value
            items.append(MenuInfoItem(title: "\(country.flagEmoji) \(name)"))
        }
        items += info.addresses.map { publicAddressItem($0, isHidden: isHidden) }
        if let leakedCountry = info.leakedIPv6Country {
            let name = locale.localizedString(forRegionCode: leakedCountry.value) ?? leakedCountry.value
            items.append(MenuInfoItem(title: String(localized: "⚠️ IPv6 leak: \(leakedCountry.flagEmoji) \(name)")))
        }
        guard !isHidden else {
            return items
        }
        if let city = info.city {
            items.append(MenuInfoItem(title: String(localized: "City: \(city)")))
        }
        if let organization = info.organization {
            items.append(MenuInfoItem(title: String(localized: "Provider: \(organization)")))
        }
        return items
    }

    private static func publicAddressItem(_ address: IPAddress, isHidden: Bool) -> MenuInfoItem {
        let mask = isHidden ? PrivacyPreferences.masked(address.value) : nil
        return MenuInfoItem(
            title: String(localized: "Public \(versionName(address.version)): \(mask ?? address.value)"),
            copyValue: address.value,
            maskedSuffix: mask
        )
    }

    private static func localAddressItem(_ local: LocalAddress, isHidden: Bool) -> MenuInfoItem {
        let mask = isHidden ? PrivacyPreferences.masked(local.address.value) : nil
        return MenuInfoItem(
            title: String(localized: "Local IP (\(local.interfaceName)): \(mask ?? local.address.value)"),
            copyValue: local.address.value,
            maskedSuffix: mask
        )
    }

    private static func versionName(_ version: IPAddress.Version) -> String {
        switch version {
        case .v4:
            "IPv4"
        case .v6:
            "IPv6"
        }
    }
}
