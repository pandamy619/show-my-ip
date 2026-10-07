import Foundation

struct CountryOption: Identifiable, Equatable {
    let code: CountryCode
    let name: String

    var id: String { code.value }
    var title: String { "\(code.flagEmoji) \(name)" }
}

enum CountryOptions {
    static func all(locale: Locale) -> [CountryOption] {
        Locale.Region.isoRegions
            .compactMap { region in
                guard let code = CountryCode(region.identifier),
                    let name = locale.localizedString(forRegionCode: code.value)
                else {
                    return nil
                }
                return CountryOption(code: code, name: name)
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
