import AppKit
import Observation

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private static let maskedFont = NSFont.monospacedSystemFont(
        ofSize: NSFont.menuBarFont(ofSize: 0).pointSize,
        weight: .regular
    )

    private static let regularFont = NSFont.menuBarFont(ofSize: 0)
    private static let spoilerHeight: CGFloat = 16

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let spoilerView = SpoilerView()
    private let menu = NSMenu()
    private let infoItemFactory = InfoMenuItemFactory()
    private let history: IPHistory
    private let historyMenuFactory: HistoryMenuFactory
    private let mapMenuFactory: MapMenuFactory
    private let appState: AppState
    private let screenObserver: ScreenObserver
    private let privacyState: PrivacyState
    private let notificationCoordinator: NotificationCoordinator
    private let settingsWindowController: SettingsWindowController
    private let defaults: UserDefaults
    private var lastHandledStatus: AppState.Status?
    private var defaultsObserver: (any NSObjectProtocol)?
    private var showsLocationDetails: Bool

    init(
        appState: AppState,
        screenObserver: ScreenObserver,
        privacyState: PrivacyState,
        notificationCoordinator: NotificationCoordinator,
        settingsWindowController: SettingsWindowController,
        history: IPHistory,
        defaults: UserDefaults = .standard
    ) {
        self.appState = appState
        self.screenObserver = screenObserver
        self.privacyState = privacyState
        self.notificationCoordinator = notificationCoordinator
        self.settingsWindowController = settingsWindowController
        self.history = history
        historyMenuFactory = HistoryMenuFactory(history: history, infoItemFactory: infoItemFactory)
        mapMenuFactory = MapMenuFactory(defaults: defaults)
        self.defaults = defaults
        showsLocationDetails = defaults.bool(forKey: SettingsKey.showsLocationDetails)
        super.init()
        menu.delegate = self
        configureButton()
        observeDefaults()
        observeState()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        if let mapItem = mapMenuFactory.makeItem(for: appState.status, isHidden: privacyState.isHidden) {
            menu.addItem(mapItem)
        }
        let infoItems = MenuInfoBuilder.items(
            for: appState.status,
            localAddresses: appState.localAddresses,
            locale: .current,
            isHidden: privacyState.isHidden
        )
        let hiddenStyle = PrivacyPreferences.load(from: defaults).hiddenStyle
        infoItems.forEach { menu.addItem(infoItemFactory.makeItem($0, hiddenStyle: hiddenStyle)) }
        menu.addItem(.separator())
        if history.isEnabled {
            menu.addItem(historyMenuFactory.makeItem(isHidden: privacyState.isHidden, hiddenStyle: hiddenStyle))
            menu.addItem(.separator())
        }
        menu.addItem(makeActionItem(String(localized: "Refresh"), action: #selector(refresh), key: "r"))
        menu.addItem(makeActionItem(String(localized: "Settings…"), action: #selector(openSettings), key: ","))
        menu.addItem(.separator())
        menu.addItem(makeActionItem(String(localized: "Quit"), action: #selector(quit), key: "q"))
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }
        button.target = self
        button.action = #selector(statusItemClicked)
        spoilerView.isHidden = true
        button.addSubview(spoilerView)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func observeDefaults() {
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: defaults,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.defaultsDidChange()
            }
        }
    }

    private func observeState() {
        withObservationTracking {
            renderLabel()
            statusDidChange()
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.observeState()
            }
        }
    }

    private func renderLabel() {
        let visibleLabel = makeLabel(isHidden: false)
        let hiddenLabel = makeLabel(isHidden: true)
        guard privacyState.isHidden, hiddenLabel != visibleLabel else {
            apply(visibleLabel)
            statusItem.length = NSStatusItem.variableLength
            spoilerView.isHidden = true
            return
        }
        let style = PrivacyPreferences.load(from: defaults).hiddenStyle
        apply(visibleLabel)
        let visibleWidth = statusItem.button?.intrinsicContentSize.width ?? 0
        apply(hiddenLabel, maskedWith: style)
        let maskedWidth = statusItem.button?.intrinsicContentSize.width ?? 0
        // Keeps the menu bar item at least as wide as the real address so hiding it does not shift neighbouring icons.
        statusItem.length = max(visibleWidth, maskedWidth)
        layoutSpoiler(over: hiddenLabel, style: style)
    }

    private func makeLabel(isHidden: Bool) -> MenuBarLabel {
        let settings = DisplaySettings.load(from: defaults)
        return MenuBarLabel.make(
            for: appState.status,
            isCompact: settings.displayMode.isCompact(hasNotchedScreen: screenObserver.hasNotchedScreen),
            compactStyle: settings.compactStyle,
            preferredVersion: settings.menuBarAddress.version,
            isHidden: isHidden
        )
    }

    private func apply(_ label: MenuBarLabel, maskedWith style: HiddenStyle? = nil) {
        guard let button = statusItem.button else {
            return
        }
        switch label {
        case .text(let text):
            button.image = nil
            if let style {
                button.attributedTitle = maskedTitle(text, showsMask: !style.usesSpoiler)
            } else {
                button.title = text
            }
        case .symbol(let name):
            button.title = ""
            button.image = NSImage(systemSymbolName: name, accessibilityDescription: "Show My IP")
            button.image?.isTemplate = true
        }
    }

    private func maskedTitle(_ text: String, showsMask: Bool) -> NSAttributedString {
        guard let parts = MenuBarLabel.splitAddress(in: text) else {
            return NSAttributedString(string: text, attributes: [.font: Self.maskedFont])
        }
        var addressAttributes: [NSAttributedString.Key: Any] = [.font: Self.maskedFont]
        if !showsMask {
            addressAttributes[.foregroundColor] = NSColor.clear
        }
        let title = NSMutableAttributedString(string: parts.prefix, attributes: [.font: Self.regularFont])
        title.append(NSAttributedString(string: parts.address, attributes: addressAttributes))
        return title
    }

    private func layoutSpoiler(over label: MenuBarLabel, style: HiddenStyle) {
        guard style.usesSpoiler,
            case .text(let text) = label,
            let parts = MenuBarLabel.splitAddress(in: text),
            let button = statusItem.button
        else {
            spoilerView.isHidden = true
            return
        }
        let titleWidth = maskedTitle(text, showsMask: false).size().width
        let prefixWidth = NSAttributedString(string: parts.prefix, attributes: [.font: Self.regularFont]).size().width
        let addressWidth = NSAttributedString(string: parts.address, attributes: [.font: Self.maskedFont]).size().width
        let height = min(button.bounds.height, Self.spoilerHeight)
        spoilerView.frame = NSRect(
            x: (statusItem.length - titleWidth) / 2 + prefixWidth,
            y: (button.bounds.height - height) / 2,
            width: addressWidth,
            height: height
        )
        spoilerView.style = style
        spoilerView.isHidden = false
    }

    private func statusDidChange() {
        let status = appState.status
        guard status != lastHandledStatus else {
            return
        }
        lastHandledStatus = status
        if case .loaded(let info) = status {
            history.record(info, at: Date())
        }
        notificationCoordinator.handle(
            status,
            preferences: .load(from: defaults),
            isHidden: privacyState.isHidden
        )
    }

    private func makeActionItem(_ title: String, action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func statusItemClicked() {
        let modifiers = NSApplication.shared.currentEvent?.modifierFlags ?? []
        switch StatusItemClick.action(modifiers: modifiers, allowsHiding: privacyState.allowsHiding) {
        case .toggleHidden:
            privacyState.toggle()
        case .openMenu:
            openMenu()
        }
    }

    private func openMenu() {
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    private func defaultsDidChange() {
        privacyState.preferencesDidChange()
        history.preferencesDidChange()
        renderLabel()
        let shows = defaults.bool(forKey: SettingsKey.showsLocationDetails)
        guard shows != showsLocationDetails else {
            return
        }
        showsLocationDetails = shows
        refresh()
    }

    @objc private func refresh() {
        Task { await appState.refresh() }
    }

    @objc private func openSettings() {
        settingsWindowController.show()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
