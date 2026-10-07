import Foundation

struct MenuInfoItem: Equatable, Identifiable {
    let title: String
    let copyValue: String?

    var id: String { title }

    init(title: String, copyValue: String? = nil) {
        self.title = title
        self.copyValue = copyValue
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
            [MenuInfoItem(title: "Loading…")]
        case .offline:
            [MenuInfoItem(title: "No network connection")]
        case .failed:
            [MenuInfoItem(title: "Could not determine public IP")]
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
        let address = info.address.value
        let shownAddress = isHidden ? PrivacyPreferences.masked(address) : address
        let title = "Public \(versionName(info.address.version)): \(shownAddress)"
        items.append(MenuInfoItem(title: title, copyValue: address))
        guard !isHidden else {
            return items
        }
        if let city = info.city {
            items.append(MenuInfoItem(title: "City: \(city)"))
        }
        if let organization = info.organization {
            items.append(MenuInfoItem(title: "Provider: \(organization)"))
        }
        return items
    }

    private static func localAddressItem(_ local: LocalAddress, isHidden: Bool) -> MenuInfoItem {
        let shownAddress = isHidden ? PrivacyPreferences.masked(local.address.value) : local.address.value
        return MenuInfoItem(
            title: "Local IP (\(local.interfaceName)): \(shownAddress)",
            copyValue: local.address.value
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
