import AppKit
import MapKit

@MainActor
final class MapSnapshotter {
    static let size = NSSize(width: 480, height: 150)

    private struct CacheKey: Equatable {
        let location: MapLocation
        let appearance: NSAppearance.Name
    }

    private var cached: (key: CacheKey, image: NSImage)?
    private var pending: MKMapSnapshotter?

    func cachedImage(for location: MapLocation, appearance: NSAppearance) -> NSImage? {
        guard let cached, cached.key == Self.key(location, appearance) else {
            return nil
        }
        return cached.image
    }

    func requestImage(
        for location: MapLocation,
        appearance: NSAppearance,
        completion: @escaping @MainActor @Sendable (NSImage) -> Void
    ) {
        if let image = cachedImage(for: location, appearance: appearance) {
            completion(image)
            return
        }
        let key = Self.key(location, appearance)
        let snapshotter = MKMapSnapshotter(options: Self.options(for: location.region, appearance: appearance))
        pending?.cancel()
        pending = snapshotter
        snapshotter.start(with: .main) { [weak self] snapshot, error in
            let imageData = snapshot?.image.tiffRepresentation
            MainActor.assumeIsolated {
                guard let self, let imageData, let image = NSImage(data: imageData) else {
                    if let error {
                        let reason = error.localizedDescription
                        AppLogger.ipLookup.warning("Map snapshot failed: \(reason, privacy: .public)")
                    }
                    return
                }
                self.cached = (key, image)
                self.pending = nil
                completion(image)
            }
        }
    }

    private static func key(_ location: MapLocation, _ appearance: NSAppearance) -> CacheKey {
        CacheKey(location: location, appearance: appearance.name)
    }

    private static func options(for region: MapRegion, appearance: NSAppearance) -> MKMapSnapshotter.Options {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude),
            span: MKCoordinateSpan(latitudeDelta: region.latitudeSpan, longitudeDelta: region.longitudeSpan)
        )
        options.size = size
        options.appearance = appearance
        options.pointOfInterestFilter = .excludingAll
        return options
    }
}
