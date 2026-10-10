enum IPNotification: Equatable, Sendable {
    case countryChanged(from: CountryCode?, to: CountryCode?)
    case addressChanged(from: IPAddress, to: IPAddress)
    case homeCountryDetected(CountryCode)
    case ipv6Leak(ipv4Country: CountryCode, ipv6Country: CountryCode)
    case connectionLost
    case vpnDisconnected
    case dnsLeak(ipCountry: CountryCode, dnsCountry: CountryCode)
}
