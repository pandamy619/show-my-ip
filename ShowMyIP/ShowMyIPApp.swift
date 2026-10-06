import SwiftUI

@main
struct ShowMyIPApp: App {
    var body: some Scene {
        MenuBarExtra("Show My IP", systemImage: "globe") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
