struct NotificationPreferences: Equatable, Sendable {
    var isEnabled = false
    var notifiesCountryChange = true
    var notifiesAddressChange = false
    var notifiesHomeCountry = true
    var notifiesConnectionLoss = false
    var homeCountry: CountryCode?
}
