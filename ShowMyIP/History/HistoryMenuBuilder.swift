import Foundation

enum HistoryMenuBuilder {
    static let visibleCount = 10
    private static let unknownCountryEmoji = "🌐"

    static func items(
        for entries: [IPHistoryEntry],
        now: Date,
        calendar: Calendar,
        locale: Locale,
        isHidden: Bool
    ) -> [MenuInfoItem] {
        entries.prefix(visibleCount).map { entry in
            let time = timeText(for: entry.date, now: now, calendar: calendar, locale: locale)
            let flag = entry.country.flatMap(CountryCode.init)?.flagEmoji ?? unknownCountryEmoji
            let mask = isHidden ? PrivacyPreferences.masked(entry.address) : nil
            return MenuInfoItem(
                title: "\(time) · \(flag) \(mask ?? entry.address)",
                copyValue: entry.address,
                maskedSuffix: mask
            )
        }
    }

    private static func timeText(for date: Date, now: Date, calendar: Calendar, locale: Locale) -> String {
        let isToday = calendar.isDate(date, inSameDayAs: now)
        let style = Date.FormatStyle(
            date: isToday ? .omitted : .abbreviated,
            time: .shortened,
            locale: locale,
            calendar: calendar,
            timeZone: calendar.timeZone
        )
        return date.formatted(style)
    }
}
