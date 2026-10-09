import AppKit

@MainActor
final class MapMenuFactory {
    private let defaults: UserDefaults
    private lazy var mapView = MapMenuItemView { location in
        if let url = location.appleMapsURL {
            NSWorkspace.shared.open(url)
        }
    }

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func makeItem(for status: AppState.Status, isHidden: Bool) -> NSMenuItem? {
        guard let location = location(for: status, isHidden: isHidden) else {
            return nil
        }
        mapView.show(location)
        let item = NSMenuItem()
        item.view = mapView
        return item
    }

    private func location(for status: AppState.Status, isHidden: Bool) -> MapLocation? {
        guard defaults.bool(forKey: SettingsKey.showsMap), !isHidden, case .loaded(let info) = status else {
            return nil
        }
        return MapLocation.make(for: info, locale: .current)
    }
}
