import AppKit

@MainActor
final class HistoryMenuFactory: NSObject {
    private let history: IPHistory
    private let infoItemFactory: InfoMenuItemFactory

    init(history: IPHistory, infoItemFactory: InfoMenuItemFactory) {
        self.history = history
        self.infoItemFactory = infoItemFactory
    }

    func makeItem(isHidden: Bool, hiddenStyle: HiddenStyle) -> NSMenuItem {
        let item = NSMenuItem(title: String(localized: "History"), action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        let entries = HistoryMenuBuilder.items(
            for: history.entries,
            now: Date(),
            calendar: .current,
            locale: .current,
            isHidden: isHidden
        )
        if entries.isEmpty {
            submenu.addItem(NSMenuItem(title: String(localized: "No changes yet"), action: nil, keyEquivalent: ""))
        } else {
            entries.forEach { submenu.addItem(infoItemFactory.makeItem($0, hiddenStyle: hiddenStyle)) }
            submenu.addItem(.separator())
            let clearItem = NSMenuItem(
                title: String(localized: "Clear History"),
                action: #selector(clearHistory),
                keyEquivalent: ""
            )
            clearItem.target = self
            submenu.addItem(clearItem)
        }
        item.submenu = submenu
        return item
    }

    @objc private func clearHistory() {
        history.clear()
    }
}
