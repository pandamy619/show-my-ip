struct VPNStatus: Equatable, Sendable {
    let interfaceName: String?

    var isActive: Bool {
        interfaceName != nil
    }
}
