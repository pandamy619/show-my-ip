import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.pandamy619.ShowMyIP"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let ipLookup = Logger(subsystem: subsystem, category: "ip-lookup")
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
    static let settings = Logger(subsystem: subsystem, category: "settings")
}
