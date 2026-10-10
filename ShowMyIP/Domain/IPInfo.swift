struct IPInfo: Equatable, Sendable {
    let address: IPAddress
    let secondaryAddress: IPAddress?
    let secondaryCountry: CountryCode?
    let country: CountryCode?
    let city: String?
    let organization: String?
    let coordinate: Coordinate?
    let dnsResolver: DNSResolver?

    init(
        address: IPAddress,
        country: CountryCode?,
        city: String? = nil,
        organization: String? = nil,
        coordinate: Coordinate? = nil,
        secondaryAddress: IPAddress? = nil,
        secondaryCountry: CountryCode? = nil,
        dnsResolver: DNSResolver? = nil
    ) {
        self.address = address
        self.secondaryAddress = secondaryAddress
        self.secondaryCountry = secondaryCountry
        self.country = country
        self.city = city
        self.organization = organization
        self.coordinate = coordinate
        self.dnsResolver = dnsResolver
    }

    var addresses: [IPAddress] {
        [address] + (secondaryAddress.map { [$0] } ?? [])
    }

    func address(of version: IPAddress.Version) -> IPAddress? {
        addresses.first { $0.version == version }
    }

    var leakedIPv6Country: CountryCode? {
        guard
            address.version == .v4, secondaryAddress?.version == .v6,
            let country, let secondaryCountry, country != secondaryCountry
        else {
            return nil
        }
        return secondaryCountry
    }

    func withSecondaryAddress(_ secondaryAddress: IPAddress, country secondaryCountry: CountryCode? = nil) -> IPInfo {
        IPInfo(
            address: address,
            country: country,
            city: city,
            organization: organization,
            coordinate: coordinate,
            secondaryAddress: secondaryAddress,
            secondaryCountry: secondaryCountry,
            dnsResolver: dnsResolver
        )
    }

    var dnsLeakCountry: CountryCode? {
        guard let country, let resolverCountry = dnsResolver?.country, resolverCountry != country else {
            return nil
        }
        return resolverCountry
    }

    func withDNSResolver(_ dnsResolver: DNSResolver) -> IPInfo {
        IPInfo(
            address: address,
            country: country,
            city: city,
            organization: organization,
            coordinate: coordinate,
            secondaryAddress: secondaryAddress,
            secondaryCountry: secondaryCountry,
            dnsResolver: dnsResolver
        )
    }
}
