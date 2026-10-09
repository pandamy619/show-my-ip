struct IPInfo: Equatable, Sendable {
    let address: IPAddress
    let secondaryAddress: IPAddress?
    let country: CountryCode?
    let city: String?
    let organization: String?
    let coordinate: Coordinate?

    init(
        address: IPAddress,
        country: CountryCode?,
        city: String? = nil,
        organization: String? = nil,
        coordinate: Coordinate? = nil,
        secondaryAddress: IPAddress? = nil
    ) {
        self.address = address
        self.secondaryAddress = secondaryAddress
        self.country = country
        self.city = city
        self.organization = organization
        self.coordinate = coordinate
    }

    var addresses: [IPAddress] {
        [address] + (secondaryAddress.map { [$0] } ?? [])
    }

    func address(of version: IPAddress.Version) -> IPAddress? {
        addresses.first { $0.version == version }
    }

    func withSecondaryAddress(_ secondaryAddress: IPAddress) -> IPInfo {
        IPInfo(
            address: address,
            country: country,
            city: city,
            organization: organization,
            coordinate: coordinate,
            secondaryAddress: secondaryAddress
        )
    }
}
