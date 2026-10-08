#if DEBUG
    import Foundation

    enum DemoMode {
        static let launchArgumentKey = "DemoMode"
        static let defaultsSuiteName = "ShowMyIP.demo"

        static var isEnabled: Bool {
            UserDefaults.standard.bool(forKey: launchArgumentKey)
        }

        static var localAddresses: [LocalAddress] {
            guard let address = IPAddress("192.168.1.23") else {
                return []
            }
            return [LocalAddress(interfaceName: "en0", address: address)]
        }
    }

    actor DemoIPProvider: IPProvider {
        private struct Snapshot {
            let address: String
            let ipv6: String?
            let country: String
            let city: String
            let organization: String
        }

        private static let snapshots = [
            Snapshot(
                address: "203.0.113.42",
                ipv6: "2001:db8::42",
                country: "NL",
                city: "Amsterdam",
                organization: "Example Networks B.V."
            ),
            Snapshot(
                address: "198.51.100.7",
                ipv6: nil,
                country: "DE",
                city: "Frankfurt am Main",
                organization: "Sample Telecom GmbH"
            ),
        ]

        private var index = 0

        func fetchIPInfo() async throws(IPProviderError) -> IPInfo {
            let snapshot = Self.snapshots[index % Self.snapshots.count]
            index += 1
            guard let address = IPAddress(snapshot.address) else {
                throw .invalidResponse
            }
            return IPInfo(
                address: address,
                country: CountryCode(snapshot.country),
                city: snapshot.city,
                organization: snapshot.organization,
                secondaryAddress: snapshot.ipv6.flatMap(IPAddress.init)
            )
        }
    }
#endif
