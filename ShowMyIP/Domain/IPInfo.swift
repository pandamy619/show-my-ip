struct IPInfo: Equatable, Sendable {
    let address: IPAddress
    let country: CountryCode?
    let city: String?
    let organization: String?

    init(address: IPAddress, country: CountryCode?, city: String? = nil, organization: String? = nil) {
        self.address = address
        self.country = country
        self.city = city
        self.organization = organization
    }
}
