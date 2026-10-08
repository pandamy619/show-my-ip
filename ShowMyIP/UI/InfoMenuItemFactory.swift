import AppKit

@MainActor
final class InfoMenuItemFactory: NSObject {
    private static let menuFont = NSFont.menuFont(ofSize: 0)
    private static let maskedMenuFont = NSFont.monospacedSystemFont(ofSize: menuFont.pointSize, weight: .regular)

    func makeItem(_ info: MenuInfoItem, hiddenStyle: HiddenStyle) -> NSMenuItem {
        let item = NSMenuItem(title: info.title, action: nil, keyEquivalent: "")
        if let copyValue = info.copyValue {
            item.action = #selector(copyRepresentedValue(_:))
            item.target = self
            item.representedObject = copyValue
        }
        if let mask = info.maskedSuffix {
            decorateMaskedItem(item, info: info, mask: mask, style: hiddenStyle)
        }
        return item
    }

    private func decorateMaskedItem(_ item: NSMenuItem, info: MenuInfoItem, mask: String, style: HiddenStyle) {
        guard style.usesSpoiler else {
            let title = NSMutableAttributedString(string: info.unmaskedPrefix, attributes: [.font: Self.menuFont])
            title.append(NSAttributedString(string: mask, attributes: [.font: Self.maskedMenuFont]))
            item.attributedTitle = title
            return
        }
        let copyValue = info.copyValue
        item.view = SpoilerMenuItemView(
            prefix: info.unmaskedPrefix,
            maskedText: mask,
            style: style,
            font: Self.menuFont,
            maskFont: Self.maskedMenuFont
        ) { [weak self] in
            if let copyValue {
                self?.copy(copyValue)
            }
        }
    }

    @objc private func copyRepresentedValue(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String else {
            return
        }
        copy(value)
    }

    private func copy(_ value: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
}
