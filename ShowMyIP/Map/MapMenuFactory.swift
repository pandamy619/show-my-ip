import AppKit

@MainActor
final class MapMenuFactory {
    private let snapshotter = MapSnapshotter()
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func makeItem(for status: AppState.Status, isHidden: Bool) -> NSMenuItem? {
        guard let location = location(for: status, isHidden: isHidden) else {
            return nil
        }
        let view = MapMenuItemView(title: location.title) {
            if let url = location.appleMapsURL {
                NSWorkspace.shared.open(url)
            }
        }
        let appearance = NSApp.effectiveAppearance
        view.image = snapshotter.cachedImage(for: location, appearance: appearance)
        if view.image == nil {
            snapshotter.requestImage(for: location, appearance: appearance) { [weak view] image in
                view?.image = image
            }
        }
        let item = NSMenuItem()
        item.view = view
        return item
    }

    func prefetch(for status: AppState.Status, isHidden: Bool) {
        guard let location = location(for: status, isHidden: isHidden) else {
            return
        }
        snapshotter.requestImage(for: location, appearance: NSApp.effectiveAppearance) { _ in }
    }

    private func location(for status: AppState.Status, isHidden: Bool) -> MapLocation? {
        guard defaults.bool(forKey: SettingsKey.showsMap), !isHidden, case .loaded(let info) = status else {
            return nil
        }
        return MapLocation.make(for: info, locale: .current)
    }
}
