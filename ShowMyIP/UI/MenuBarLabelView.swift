import SwiftUI

struct MenuBarLabelView: View {
    let label: MenuBarLabel

    var body: some View {
        switch label {
        case .text(let text):
            Text(text)
        case .symbol(let name):
            Image(systemName: name)
        }
    }
}
