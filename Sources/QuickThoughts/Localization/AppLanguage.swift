import Foundation

enum AppLanguage: String, CaseIterable, Codable {
    case auto
    case english
    case chinese

    func displayName(in lang: EffectiveLanguage) -> String {
        switch (self, lang) {
        case (.auto, .english): return "Auto"
        case (.auto, .chinese): return "自动"
        case (.english, _): return "English"
        case (.chinese, _): return "中文"
        }
    }
}

enum EffectiveLanguage {
    case english
    case chinese
}
