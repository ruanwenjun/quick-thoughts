import Foundation
import Combine

@MainActor
final class Localizer: ObservableObject {
    static let shared = Localizer()

    private static let storageKey = "quickthoughts.language"

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey) }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let lang = AppLanguage(rawValue: raw) {
            self.language = lang
        } else {
            self.language = .auto
        }
    }

    var effective: EffectiveLanguage {
        switch language {
        case .english: return .english
        case .chinese: return .chinese
        case .auto: return Self.systemLanguage()
        }
    }

    func t(_ key: L10n) -> String {
        key.text(for: effective)
    }

    func t(_ failure: LoadFailure) -> String {
        switch failure {
        case .unsupportedSchema(let v): return t(.storeUnsupportedSchema(v))
        case .generic(let msg): return t(.storeLoadFailed(msg))
        }
    }

    private static func systemLanguage() -> EffectiveLanguage {
        let preferred = (Locale.preferredLanguages.first ?? "en").lowercased()
        return preferred.hasPrefix("zh") ? .chinese : .english
    }
}
