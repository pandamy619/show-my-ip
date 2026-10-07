import AppKit

@MainActor
final class SpoilerMenuItemView: NSView {
    private static let horizontalInset: CGFloat = 14
    private static let rowHeight: CGFloat = 22
    private static let spoilerHeight: CGFloat = 14
    private static let highlightInset: CGFloat = 5
    private static let highlightRadius: CGFloat = 4

    private let label: NSTextField
    private let spoiler = SpoilerView()
    private let onSelect: @MainActor () -> Void

    private var isHighlighted: Bool {
        enclosingMenuItem?.isHighlighted ?? false
    }

    init(
        prefix: String,
        maskedText: String,
        style: HiddenStyle,
        font: NSFont,
        maskFont: NSFont,
        onSelect: @escaping @MainActor () -> Void
    ) {
        label = NSTextField(labelWithString: prefix)
        label.font = font
        self.onSelect = onSelect
        let labelSize = label.intrinsicContentSize
        let maskWidth = ceil(NSAttributedString(string: maskedText, attributes: [.font: maskFont]).size().width)
        let width = Self.horizontalInset * 2 + ceil(labelSize.width) + maskWidth
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: Self.rowHeight))
        autoresizingMask = [.width]
        label.frame = NSRect(
            x: Self.horizontalInset,
            y: (Self.rowHeight - labelSize.height) / 2,
            width: ceil(labelSize.width),
            height: labelSize.height
        )
        spoiler.frame = NSRect(
            x: label.frame.maxX,
            y: (Self.rowHeight - Self.spoilerHeight) / 2,
            width: maskWidth,
            height: Self.spoilerHeight
        )
        spoiler.style = style
        addSubview(label)
        addSubview(spoiler)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(
            NSTrackingArea(
                rect: .zero,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self
            )
        )
    }

    override func mouseEntered(with event: NSEvent) {
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let textColor: NSColor = isHighlighted ? .selectedMenuItemTextColor : .labelColor
        label.textColor = textColor
        spoiler.color = textColor
        guard isHighlighted else {
            return
        }
        NSColor.selectedContentBackgroundColor.setFill()
        let highlight = bounds.insetBy(dx: Self.highlightInset, dy: 0)
        NSBezierPath(roundedRect: highlight, xRadius: Self.highlightRadius, yRadius: Self.highlightRadius).fill()
    }

    override func mouseUp(with event: NSEvent) {
        enclosingMenuItem?.menu?.cancelTracking()
        onSelect()
    }
}
