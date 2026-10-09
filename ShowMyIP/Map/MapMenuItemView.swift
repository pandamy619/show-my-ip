import AppKit

@MainActor
final class MapMenuItemView: NSView {
    private static let inset: CGFloat = 10
    private static let minimumMapWidth: CGFloat = 280
    private static let verticalPadding: CGFloat = 4
    private static let cornerRadius: CGFloat = 8
    private static let pinSize: CGFloat = 12
    private static let pinBorder: CGFloat = 2

    private let mapView = NSView()
    private let pin = NSView()
    private let onSelect: @MainActor () -> Void

    var image: NSImage? {
        didSet { mapView.layer?.contents = image }
    }

    init(title: String, onSelect: @escaping @MainActor () -> Void) {
        self.onSelect = onSelect
        let mapSize = NSSize(width: Self.minimumMapWidth, height: MapSnapshotter.size.height)
        super.init(
            frame: NSRect(
                x: 0,
                y: 0,
                width: mapSize.width + Self.inset * 2,
                height: mapSize.height + Self.verticalPadding * 2
            )
        )
        autoresizingMask = [.width]

        mapView.frame = NSRect(origin: NSPoint(x: Self.inset, y: Self.verticalPadding), size: mapSize)
        mapView.autoresizingMask = [.width]
        mapView.wantsLayer = true
        mapView.layer?.contentsGravity = .resizeAspectFill
        mapView.layer?.cornerRadius = Self.cornerRadius
        mapView.layer?.masksToBounds = true
        mapView.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        mapView.setAccessibilityElement(true)
        mapView.setAccessibilityRole(.image)
        mapView.setAccessibilityLabel(title)
        addSubview(mapView)

        pin.frame = NSRect(
            x: mapView.frame.midX - Self.pinSize / 2,
            y: mapView.frame.midY - Self.pinSize / 2,
            width: Self.pinSize,
            height: Self.pinSize
        )
        pin.autoresizingMask = [.minXMargin, .maxXMargin]
        pin.wantsLayer = true
        pin.layer?.cornerRadius = Self.pinSize / 2
        pin.layer?.backgroundColor = NSColor.systemRed.cgColor
        pin.layer?.borderColor = NSColor.white.cgColor
        pin.layer?.borderWidth = Self.pinBorder
        addSubview(pin)
        toolTip = title
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func mouseUp(with event: NSEvent) {
        enclosingMenuItem?.menu?.cancelTracking()
        onSelect()
    }
}
