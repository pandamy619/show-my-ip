import AppKit
import MapKit

@MainActor
final class MapMenuItemView: NSView {
    private static let inset: CGFloat = 10
    private static let verticalPadding: CGFloat = 4
    private static let minimumMapWidth: CGFloat = 280
    private static let mapHeight: CGFloat = 170
    private static let cornerRadius: CGFloat = 8
    private static let buttonSize: CGFloat = 26
    private static let buttonMargin: CGFloat = 6
    private static let openSymbol = "arrow.up.forward.app"

    private let mapView = MKMapView()
    private let pin = MKPointAnnotation()
    private let openButton = NSButton()
    private let onOpen: @MainActor (MapLocation) -> Void
    private var location: MapLocation?

    init(onOpen: @escaping @MainActor (MapLocation) -> Void) {
        self.onOpen = onOpen
        let mapSize = NSSize(width: Self.minimumMapWidth, height: Self.mapHeight)
        super.init(
            frame: NSRect(
                x: 0,
                y: 0,
                width: mapSize.width + Self.inset * 2,
                height: mapSize.height + Self.verticalPadding * 2
            )
        )
        autoresizingMask = [.width]
        configureMap(frame: NSRect(origin: NSPoint(x: Self.inset, y: Self.verticalPadding), size: mapSize))
        configureOpenButton()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func show(_ location: MapLocation) {
        guard location != self.location else {
            return
        }
        self.location = location
        let center = CLLocationCoordinate2D(
            latitude: location.region.center.latitude,
            longitude: location.region.center.longitude
        )
        pin.coordinate = center
        pin.title = location.title
        let span = MKCoordinateSpan(
            latitudeDelta: location.region.latitudeSpan,
            longitudeDelta: location.region.longitudeSpan
        )
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
    }

    private func configureMap(frame: NSRect) {
        mapView.frame = frame
        mapView.autoresizingMask = [.width]
        mapView.wantsLayer = true
        mapView.layer?.cornerRadius = Self.cornerRadius
        mapView.layer?.masksToBounds = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsZoomControls = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.addAnnotation(pin)
        addSubview(mapView)
    }

    private func configureOpenButton() {
        let title = String(localized: "Open in Maps")
        openButton.image = NSImage(systemSymbolName: Self.openSymbol, accessibilityDescription: title)
        openButton.bezelStyle = .circular
        openButton.toolTip = title
        openButton.target = self
        openButton.action = #selector(openInMaps)
        openButton.frame = NSRect(
            x: mapView.frame.maxX - Self.buttonSize - Self.buttonMargin,
            y: mapView.frame.maxY - Self.buttonSize - Self.buttonMargin,
            width: Self.buttonSize,
            height: Self.buttonSize
        )
        openButton.autoresizingMask = [.minXMargin, .minYMargin]
        addSubview(openButton)
    }

    @objc private func openInMaps() {
        guard let location else {
            return
        }
        enclosingMenuItem?.menu?.cancelTracking()
        onOpen(location)
    }
}
