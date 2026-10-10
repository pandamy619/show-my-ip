struct DNSResolver: Equatable, Sendable {
    let address: IPAddress
    let country: CountryCode?
    let organization: String?
}
