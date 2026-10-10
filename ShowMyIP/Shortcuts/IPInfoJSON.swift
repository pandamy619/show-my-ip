import Foundation

enum IPInfoJSON {
    private struct Payload: Encodable {
        let ip: String?
        let ipv6: String?
        let country: String?
        let city: String?
        let provider: String?
        let vpn: Bool?
    }

    static func encode(_ info: IPInfo, vpnStatus: VPNStatus?) -> String {
        let payload = Payload(
            ip: info.address(of: .v4)?.value,
            ipv6: info.address(of: .v6)?.value,
            country: info.country?.value,
            city: info.city,
            provider: info.organization,
            vpn: vpnStatus?.isActive
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(payload), let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}
