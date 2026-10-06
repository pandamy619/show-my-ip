import AppKit
import SwiftUI

struct MenuInfoView: View {
    let items: [MenuInfoItem]

    var body: some View {
        ForEach(items) { item in
            if let copyValue = item.copyValue {
                Button(item.title) {
                    copyToPasteboard(copyValue)
                }
            } else {
                Text(item.title)
            }
        }
    }

    private func copyToPasteboard(_ value: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
}
