import Foundation
import Testing
@testable import ShowMyIP

struct LocalizationTests {
    private static func russianTable() throws -> [String: String] {
        let bundle = Bundle(for: StatusItemController.self)
        let url = try #require(
            bundle.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "ru")
        )
        return try #require(NSDictionary(contentsOf: url) as? [String: String])
    }

    private static func placeholderCount(in text: String) -> Int {
        text.components(separatedBy: "%@").count - 1
    }

    @Test(arguments: [
        ("Refresh", "Обновить"),
        ("Settings…", "Настройки…"),
        ("Quit", "Выйти"),
        ("Public %@: %@", "Публичный %@: %@"),
        ("Local IP (%@): %@", "Локальный IP (%@): %@"),
        ("Country changed", "Страна изменилась"),
        ("Animated spoiler", "Анимированный спойлер"),
        ("Privacy", "Приватность"),
        ("Address", "Адрес"),
        ("Show city and provider", "Показывать город и провайдера"),
        ("History", "История"),
        ("Show map", "Показывать карту"),
        ("Keep IP history", "Вести историю IP"),
    ])
    func translatesToRussian(key: String, expected: String) throws {
        #expect(try Self.russianTable()[key] == expected)
    }

    @Test func russianTranslationsKeepPlaceholders() throws {
        let mismatched = try Self.russianTable()
            .filter { Self.placeholderCount(in: $0.key) != Self.placeholderCount(in: $0.value) }
            .map(\.key)
        #expect(mismatched.isEmpty)
    }

    @Test func maskedRussianItemSplitsLabelAndMask() {
        let item = MenuInfoItem(title: "Публичный IPv4: ***.*", maskedSuffix: "***.*")
        #expect(item.unmaskedPrefix == "Публичный IPv4: ")
    }
}
