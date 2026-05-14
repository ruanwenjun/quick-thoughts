<div align="center">

# 💭 Quick Thoughts

**Catch fleeting thoughts before they slip away.**

A menu bar–resident macOS app for capturing thoughts: hit a global shortcut, type, press return.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-13%2B-blue)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-native-blueviolet?logo=swift&logoColor=white)]()

**English** · [中文](README.zh-CN.md)

</div>

---

## 💡 Motivation

While coding, reading docs, or sitting in a meeting, ideas flash by: a possible cause for a bug, a small improvement, a message to send, an email to reply to. They vanish in seconds.

Opening Notion / Apple Notes / Bear is too heavy — switch apps, find the notebook, place the cursor, type, save, switch back, and the thread of thought is already broken.

Quick Thoughts does exactly one thing: **from any app, ⌥⌘T → type → Enter, three steps**. Light enough not to interrupt your flow, structured enough to browse / search / clean up later.

## ✨ Features

- ⌨️ **Global hotkey** (default `⌥⌘T`, customizable) — never break the current flow
- 📝 **Spotlight-style popup**: multi-line input, `Enter` to save, `Shift+Enter` for newline, `Esc` to cancel
- 🗂 **Draft preservation**: closing the popup (clicking outside / Esc) keeps your text for next time
- 🔍 **Full-text search**: instant filtering in the main panel, case-insensitive
- ✏️ **Inline edit / delete**: hover-revealed actions, delete asks for confirmation
- 💾 **Single-file JSON storage**: easy to back up, migrate, grep
- 🛡️ **Crash-safe**: atomic writes, auto-backup of corrupt files, schema version guard
- 🌗 **Light / dark adaptive**: follows the system appearance
- 🌐 **Bilingual UI**: English + 简体中文, switch in Settings
- 🪶 **Featherweight**: menu bar–only, no Dock icon, native Swift + SwiftUI, no Electron baggage

## 🚀 Install

### Requirements

- **Runtime**: macOS 13.0 or later
- **Build from source**: [full Xcode](https://apps.apple.com/app/xcode/id497799835) (free, Mac App Store).
  - Command Line Tools alone (`xcode-select --install`) is not enough: the `KeyboardShortcuts` dependency uses `#Preview` macros (needs the Xcode macro plugin), and `swift test` needs Xcode's bundled XCTest framework.
  - After installing Xcode, let it install additional components on first launch, then switch the toolchain:
    ```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    ```

### Option A — Download from Releases (recommended for end users)

> First release pending.

1. Grab the latest `Quick-Thoughts-x.y.z.zip` from [Releases](https://github.com/ruanwenjun/quick-thoughts/releases)
2. Unzip, drag `Quick Thoughts.app` to `/Applications`
3. **First launch**: right-click → Open → click **Open** in the warning dialog (one-time Gatekeeper bypass since the app isn't notarized yet; double-click works thereafter)

### Option B — Build from source (recommended for developers)

```bash
git clone https://github.com/ruanwenjun/quick-thoughts.git
cd quick-thoughts
make install        # → /Applications, requires sudo
# or sudo-free:
make install-user   # → ~/Applications
```

`make install` runs a release build, produces the `.app` bundle, ad-hoc signs it, and copies it to the target directory.

## 🎯 Usage

| Action | Shortcut |
| --- | --- |
| Open capture popup | `⌥⌘T` (configurable) |
| Newline in popup | `Shift+Enter` |
| Save & close popup | `Enter` |
| Cancel popup (keep draft) | `Esc` |
| Open Settings | `⌘,` |

Click the menu bar icon for "New Thought / Open Panel / Settings… / Quit".

In the main panel, **hover** any row to reveal ✏️ edit and 🗑️ delete (delete shows an inline confirmation first to prevent mistakes); the toolbar search box filters in real time.

The Settings window has a **Language** picker — `Auto / English / 中文`. `Auto` follows the system language (Chinese variants → 中文, otherwise English).

### Launch at login

The recommended path is to add `Quick Thoughts` under **System Settings → General → Login Items**.

> Settings also has a "Launch at login" toggle (built on `SMAppService`), but that API needs a properly signed app to work reliably; with the current ad-hoc–signed build it may fail — the inline red error is expected. The System Settings approach is more reliable.

## ⚙️ Data Storage

```
~/Library/Application Support/QuickThoughts/thoughts.json
```

A simple, stable format — easy to back up, grep, or migrate by hand:

```json
{
  "schemaVersion": 1,
  "thoughts": [
    {
      "id": "5C9E1F8A-...",
      "content": "Saw a nice design today",
      "createdAt": "2026-05-09T10:23:45Z",
      "updatedAt": "2026-05-09T10:23:45Z"
    }
  ]
}
```

Settings shows the current path with a "Show in Finder" button.

File I/O strategy:
- **Atomic writes**: write `thoughts.json.tmp` first, then `replaceItemAt` / `moveItem` — a crash doesn't lose the previous file
- **Debounced**: continuous edits flush 500 ms after the last keystroke; a forced flush runs on `willTerminate`
- **Corruption recovery**: JSON decode failure → backs up the original as `thoughts.json.corrupt-<timestamp>-<uuid>`, starts with an empty database
- **Schema guard**: reading a higher `schemaVersion` than supported aborts writes and prompts the user to upgrade

## 🛣️ Roadmap

**v1 shipped**: capture, browse, search, edit, delete, settings, JSON persistence, menu bar app, Spotlight-style popup, card-style main panel, bilingual UI.

**Explicitly not in v1 (YAGNI)**: iCloud sync, iOS / web clients, tags / folders, rich text / Markdown rendering, image attachments, reminders / alarms, multi-account.

**Possible future work (issues / discussion welcome)**:

- [ ] Apple Developer signing + notarization → double-click `.dmg` install, stable `SMAppService` launch-at-login
- [ ] Homebrew Cask (`brew install --cask quick-thoughts`)
- [ ] GitHub Actions CI: tag → build / sign / publish Release
- [ ] Tags / lightweight Markdown rendering
- [ ] Export / one-click zip backup

## 🛠️ Development

```bash
make build      # swift build (debug)
make test       # swift test — 16 cases covering the data layer
make run        # swift run (terminal blocks; closing it kills the app)
make bundle     # bundle .app into dist/ only
make uninstall  # remove the installed .app
make clean      # wipe .build / dist
```

### Project structure

```
Sources/QuickThoughts/
├── QuickThoughtsApp.swift                 entry; MenuBarExtra + Window + Settings
├── Models/Thought.swift                   data model
├── Storage/
│   ├── JSONFileRepository.swift           atomic write, corruption backup, schema guard
│   └── ThoughtStore.swift                 ObservableObject + CRUD + debounced flush
├── Features/
│   ├── MenuBarContent.swift               menu bar menu
│   ├── Capture/                           capture popup (NSPanel + NSTextView bridge)
│   └── Browse/                            main panel + card row
├── Localization/                          bilingual UI (Auto / English / 中文)
└── Settings/                              shortcut Recorder + login launch
```

One runtime dependency: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — global shortcut registration + SwiftUI Recorder component.

### Test coverage

```
ThoughtTests              Codable round-trip
JSONFileRepositoryTests   read / write / missing file / corrupt file / higher schema / nested dirs
ThoughtStoreTests         CRUD / whitespace trim / search / sort / flush / fatalLoadError
```

UI is not unit-tested; relies on manual smoke testing. Please attach before/after screenshots in PRs that touch UI.

## 🤝 Contributing

Issues and PRs are welcome. Before submitting:

1. `make test` passes
2. `make build` has no new warnings
3. Keep changes surgical — don't "improve" unrelated code along the way
4. UI changes should include before/after screenshots
5. Use lowercase verb-prefixed commits (`feat:` / `fix:` / `style:` / `chore:` etc.)

## 📄 License

[Apache License 2.0](LICENSE) © 2026 ruanwenjun

## 🙏 Acknowledgements

- [Sindre Sorhus](https://github.com/sindresorhus)' [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — global shortcuts + recording UI with nearly zero code
- macOS native `MenuBarExtra` / `NSPanel` / `Settings` scenes — the menu bar app substrate
