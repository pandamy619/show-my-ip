enum IPNotification: Equatable, Sendable {
    case countryChanged(from: CountryCode?, to: CountryCode?)
    case addressChanged(from: IPAddress, to: IPAddress)
    case homeCountryDetected(CountryCode)
    case connectionLost
}
