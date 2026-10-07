import AppKit
import Observation

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private static let maskedFont = NSFont.monospacedSystemFont(
        ofSize: NSFont.menuBarFont(ofSize: 0).pointSize,
        weight: .regular
    )

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let appState: AppState
    private let screenObserver: ScreenObserver
    private let privacyState: PrivacyState
    private let notificationCoordinator: NotificationCoordinator
    private let settingsWindowController: SettingsWindowController
    private let defaults: UserDefaults
    private var lastHandledStatus: AppState.Status?
    private var defaultsObserver: (any NSObjectProtocol)?

    init(
        appState: AppState,
        screenObserver: ScreenObserver,
        privacyState: PrivacyState,
        notificationCoordinator: NotificationCoordinator,
        settingsWindowController: SettingsWindowController,
        defaults: UserDefaults = .standard
    ) {
        self.appState = appState
        self.screenObserver = screenObserver
        self.privacyState = privacyState
        self.notificationCoordinator = notificationCoordinator
        self.settingsWindowController = settingsWindowController
        self.defaults = defaults
        super.init()
        menu.delegate = self
        configureButton()
        observeDefaults()
        observeState()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let infoItems = MenuInfoBuilder.items(
            for: appState.status,
            localAddresses: appState.localAddresses,
            locale: .current,
            isHidden: privacyState.isHidden
        )
        infoItems.forEach { menu.addItem(makeInfoItem($0)) }
        menu.addItem(.separator())
        menu.addItem(makeActionItem("Refresh", action: #selector(refresh), key: "r"))
        menu.addItem(makeActionItem("Settings…", action: #selector(openSettings), key: ","))
        menu.addItem(.separator())
        menu.addItem(makeActionItem("Quit", action: #selector(quit), key: "q"))
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }
        button.target = self
        button.action = #selector(statusItemClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func observeDefaults() {
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: defaults,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.privacyState.preferencesDidChange()
                self?.renderLabel()
            }
        }
    }

    private func observeState() {
        withObservationTracking {
            renderLabel()
            forwardStatusToNotifications()
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.observeState()
            }
        }
    }

    private func renderLabel() {
        let visibleLabel = makeLabel(isHidden: false)
        guard privacyState.isHidden else {
            apply(visibleLabel)
            statusItem.length = NSStatusItem.variableLength
            return
        }
        apply(visibleLabel)
        let visibleWidth = statusItem.button?.intrinsicContentSize.width ?? 0
        apply(makeLabel(isHidden: true), isMasked: true)
        let maskedWidth = statusItem.button?.intrinsicContentSize.width ?? 0
        // Keeps the menu bar item at least as wide as the real address so hiding it does not shift neighbouring icons.
        statusItem.length = max(visibleWidth, maskedWidth)
    }

    private func makeLabel(isHidden: Bool) -> MenuBarLabel {
        let settings = DisplaySettings.load(from: defaults)
        return MenuBarLabel.make(
            for: appState.status,
            isCompact: settings.displayMode.isCompact(hasNotchedScreen: screenObserver.hasNotchedScreen),
            compactStyle: settings.compactStyle,
            isHidden: isHidden
        )
    }

    private func apply(_ label: MenuBarLabel, isMasked: Bool = false) {
        guard let button = statusItem.button else {
            return
        }
        switch label {
        case .text(let text) where isMasked:
            button.image = nil
            button.attributedTitle = NSAttributedString(string: text, attributes: [.font: Self.maskedFont])
        case .text(let text):
            button.image = nil
            button.title = text
        case .symbol(let name):
            button.title = ""
            button.image = NSImage(systemSymbolName: name, accessibilityDescription: "Show My IP")
            button.image?.isTemplate = true
        }
    }

    private func forwardStatusToNotifications() {
        let status = appState.status
        guard status != lastHandledStatus else {
            return
        }
        lastHandledStatus = status
        notificationCoordinator.handle(
            status,
            preferences: .load(from: defaults),
            isHidden: privacyState.isHidden
        )
    }

    private func makeInfoItem(_ info: MenuInfoItem) -> NSMenuItem {
        let item = NSMenuItem(title: info.title, action: nil, keyEquivalent: "")
        if let copyValue = info.copyValue {
            item.action = #selector(copyToPasteboard(_:))
            item.target = self
            item.representedObject = copyValue
        }
        return item
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

    @objc private func copyToPasteboard(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String else {
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
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
