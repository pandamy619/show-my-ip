import Testing
@testable import ShowMyIP

struct AppLaunchTests {
    @Test func appModuleIsTestable() {
        #expect(ShowMyIPApp.self == ShowMyIPApp.self)
    }
}
