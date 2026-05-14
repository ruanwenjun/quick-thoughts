import Foundation

enum L10n {
    case menuNewThought
    case menuOpenPanel
    case menuSettings
    case menuQuit
    case menuSaveErrorPrefix(String)

    case capturePlaceholder
    case captureHintNewline
    case captureHintSave
    case captureHintCancel

    case mainSearchPrompt
    case mainCountTotal(Int)
    case mainCountFiltered(Int, Int)
    case mainEmptyTitle
    case mainEmptyHint
    case mainNoMatches

    case rowEditTooltip
    case rowDeleteTooltip
    case rowConfirmDelete
    case rowCancel
    case rowSave
    case rowDelete

    case settingsKeyboardShortcuts
    case settingsToggleCapture
    case settingsLaunch
    case settingsLaunchAtLogin
    case settingsLaunchError(String)
    case settingsData
    case settingsPath
    case settingsShowInFinder
    case settingsLanguage

    case storeUnsupportedSchema(Int)
    case storeLoadFailed(String)

    func text(for lang: EffectiveLanguage) -> String {
        switch self {
        case .menuNewThought:
            return pick(lang, en: "New Thought", zh: "新建想法")
        case .menuOpenPanel:
            return pick(lang, en: "Open Panel", zh: "打开面板")
        case .menuSettings:
            return pick(lang, en: "Settings…", zh: "设置...")
        case .menuQuit:
            return pick(lang, en: "Quit", zh: "退出")
        case .menuSaveErrorPrefix(let msg):
            return pick(lang, en: "⚠️ Save failed: \(msg)", zh: "⚠️ 保存失败：\(msg)")

        case .capturePlaceholder:
            return pick(lang, en: "Capture a fleeting thought…", zh: "记下一闪而过的想法…")
        case .captureHintNewline:
            return pick(lang, en: "Newline", zh: "换行")
        case .captureHintSave:
            return pick(lang, en: "Save", zh: "保存")
        case .captureHintCancel:
            return pick(lang, en: "Cancel", zh: "取消")

        case .mainSearchPrompt:
            return pick(lang, en: "Search thoughts", zh: "搜索想法")
        case .mainCountTotal(let n):
            switch lang {
            case .english: return n == 1 ? "1 thought" : "\(n) thoughts"
            case .chinese: return "共 \(n) 条想法"
            }
        case .mainCountFiltered(let m, let n):
            return pick(lang, en: "\(m) of \(n) match\(m == 1 ? "" : "es")", zh: "找到 \(m) / \(n) 条")
        case .mainEmptyTitle:
            return pick(lang, en: "No thoughts yet", zh: "还没有想法")
        case .mainEmptyHint:
            return pick(lang, en: "Press ⌥⌘T to capture your first thought", zh: "按下 ⌥⌘T 记录第一条想法")
        case .mainNoMatches:
            return pick(lang, en: "No matching thoughts", zh: "没有匹配的想法")

        case .rowEditTooltip:
            return pick(lang, en: "Edit", zh: "编辑")
        case .rowDeleteTooltip:
            return pick(lang, en: "Delete", zh: "删除")
        case .rowConfirmDelete:
            return pick(lang, en: "Delete this thought?", zh: "确认删除这条想法？")
        case .rowCancel:
            return pick(lang, en: "Cancel", zh: "取消")
        case .rowSave:
            return pick(lang, en: "Save", zh: "保存")
        case .rowDelete:
            return pick(lang, en: "Delete", zh: "删除")

        case .settingsKeyboardShortcuts:
            return pick(lang, en: "Keyboard Shortcuts", zh: "快捷键")
        case .settingsToggleCapture:
            return pick(lang, en: "Toggle capture popup", zh: "唤起捕捉弹窗")
        case .settingsLaunch:
            return pick(lang, en: "Launch", zh: "启动")
        case .settingsLaunchAtLogin:
            return pick(lang, en: "Launch Quick Thoughts at login", zh: "登录时启动 Quick Thoughts")
        case .settingsLaunchError(let msg):
            return pick(
                lang,
                en: "Toggle failed: \(msg). This feature needs a signed app bundle and may not work in development builds.",
                zh: "切换失败：\(msg)。该功能需要已签名的 App 包，开发模式下可能不可用。"
            )
        case .settingsData:
            return pick(lang, en: "Data File", zh: "数据文件")
        case .settingsPath:
            return pick(lang, en: "Path", zh: "路径")
        case .settingsShowInFinder:
            return pick(lang, en: "Show in Finder", zh: "在 Finder 中显示")
        case .settingsLanguage:
            return pick(lang, en: "Language", zh: "语言")

        case .storeUnsupportedSchema(let v):
            return pick(
                lang,
                en: "Data was written by a newer app (schema v\(v)). Please upgrade Quick Thoughts and try again.",
                zh: "数据由更新版 App (schema v\(v)) 写入，请升级 Quick Thoughts 后再试。"
            )
        case .storeLoadFailed(let msg):
            return pick(lang, en: "Failed to load data: \(msg)", zh: "无法加载数据：\(msg)")
        }
    }

    private func pick(_ lang: EffectiveLanguage, en: String, zh: String) -> String {
        switch lang {
        case .english: return en
        case .chinese: return zh
        }
    }
}
