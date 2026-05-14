<div align="center">

# 💭 Quick Thoughts

**让一闪而过的想法不再溜走。**

一个常驻菜单栏的 macOS 想法捕捉工具：按下全局快捷键，弹窗输入，回车保存。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-13%2B-blue)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-native-blueviolet?logo=swift&logoColor=white)]()

[English](README.md) · **中文**

</div>

---

## 💡 项目背景

写代码、读文档、开会，灵光一现常常出现：一个 bug 的可能成因、一个改进点子、一句想发的群消息、一个待回的邮件。这些想法一闪而过，几秒钟没记下来就忘了。

打开 Notion / Apple Notes / Bear 都太重 —— 切换到另一个 App、点进笔记本、定位光标、打字、保存、再切回来，思路已经断掉。

Quick Thoughts 想做到的就一件事：**任何 App 里 ⌥⌘T → 输入 → Enter，三步完成捕捉**。轻到不打断当前工作流，又能在事后浏览 / 搜索 / 整理。

## ✨ 特性

- ⌨️ **全局快捷键唤起**（默认 `⌥⌘T`，可自定义）—— 不打断当前工作流
- 📝 **Spotlight 风格弹窗**：多行输入，`Enter` 保存、`Shift+Enter` 换行、`Esc` 取消
- 🗂 **草稿保留**：误关弹窗（点外部 / Esc）不丢内容，下次唤起继续写
- 🔍 **全文搜索**：主面板实时过滤，大小写不敏感
- ✏️ **行内编辑 / 删除**：悬停浮出操作，删除有二次确认
- 💾 **JSON 单文件持久化**：方便备份、迁移、grep
- 🛡️ **防丢数据**：原子写、损坏文件自动备份、schema 版本守卫
- 🌗 **深 / 浅色自适应**：跟随系统外观
- 🌐 **中英双语**：English + 简体中文，设置里随时切换
- 🪶 **超轻量**：菜单栏常驻、无 Dock 图标、原生 Swift + SwiftUI、无 Electron 包袱

## 🚀 安装

### 系统要求

- **运行**：macOS 13.0 或更新
- **源码编译**：需要[完整 Xcode](https://apps.apple.com/cn/app/xcode/id497799835?mt=12)（从 Mac App Store 安装，免费）。
  - 仅装 Command Line Tools (`xcode-select --install`) 不够：依赖的 `KeyboardShortcuts` 库用到了 `#Preview` 宏（需要 Xcode 的宏插件），且 `swift test` 需要 Xcode 自带的 XCTest framework。
  - 装完 Xcode 首次启动让它装好 additional components，然后切换 toolchain：
    ```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    ```

### 方式 A — 从 Releases 下载（推荐普通用户）

> 首个 Release 待发布。

1. 到 [Releases](https://github.com/ruanwenjun/quick-thoughts/releases) 下载最新 `Quick-Thoughts-x.y.z.zip`
2. 解压，把 `Quick Thoughts.app` 拖到 `/Applications`
3. **首次启动**：右键 → 打开 → 在弹窗里再次点 **打开**（一次性绕过 Gatekeeper，因为暂未 Apple 公证；之后双击直接启动）

### 方式 B — 源码安装（推荐开发者）

```bash
git clone https://github.com/ruanwenjun/quick-thoughts.git
cd quick-thoughts
make install        # → /Applications，需要 sudo 密码
# 或免 sudo：
make install-user   # → ~/Applications
```

`make install` 会 release 编译、生成 `.app`、ad-hoc 签名、拷贝到目标目录。

## 🎯 使用

| 操作 | 快捷键 |
| --- | --- |
| 唤起捕捉弹窗 | `⌥⌘T`（设置可改） |
| 弹窗换行 | `Shift+Enter` |
| 弹窗保存并关闭 | `Enter` |
| 弹窗取消（保留草稿） | `Esc` |
| 打开设置 | `⌘,` |

菜单栏图标点开能看到 "新建想法 / 打开面板 / 设置... / 退出"。

主面板里**悬停**任意一行会浮出 ✏️ 编辑、🗑️ 删除（删除会先在行内弹一次确认，避免误删）；顶部搜索框实时过滤。

设置窗口里有 **语言** 选项 —— `Auto / English / 中文`。`Auto` 跟随系统语言（中文系列 → 中文，其它 → 英文）。

### 开机启动

推荐去「系统设置 → 通用 → 登录项」把 `Quick Thoughts` 加进去。

> 设置里也有"登录时启动"开关（基于 `SMAppService`），但这个 API 需要 App 经过正式代码签名才能稳定工作；当前 ad-hoc 签名版本可能会失败 —— 看到内联红字错误属正常。系统设置加登录项更可靠。

## ⚙️ 数据存储

```
~/Library/Application Support/QuickThoughts/thoughts.json
```

格式简单稳定，方便手工备份、grep、迁移：

```json
{
  "schemaVersion": 1,
  "thoughts": [
    {
      "id": "5C9E1F8A-...",
      "content": "今天看到一个不错的设计",
      "createdAt": "2026-05-09T10:23:45Z",
      "updatedAt": "2026-05-09T10:23:45Z"
    }
  ]
}
```

设置页能看到当前路径，并提供「在 Finder 中显示」按钮。

文件读写策略：
- **原子写**：先写 `thoughts.json.tmp`，再 `replaceItemAt` / `moveItem`，崩溃不丢老文件
- **防抖**：连续输入只在停顿 500ms 后落盘一次；进程退出（`willTerminate`）时强制 flush
- **损坏恢复**：JSON 解析失败 → 自动备份原文件为 `thoughts.json.corrupt-<timestamp>-<uuid>`，启动空数据库继续运行
- **Schema 守卫**：读到比当前更高的 `schemaVersion` 直接拒绝写入并提示用户升级 App

## 🛣️ Roadmap

**v1 已完成**：捕捉、浏览、搜索、编辑、删除、设置、JSON 持久化、菜单栏 App、Spotlight 风格弹窗、卡片化主面板、中英双语 UI。

**v1 明确不做（YAGNI）**：iCloud 同步、iOS / Web 端、标签 / 分组、富文本 / Markdown 渲染、图片附件、提醒 / 闹钟、多账户。

**未来可能（欢迎 Issue 讨论）**：

- [ ] Apple Developer 签名 + 公证 → `.dmg` 直接双击启动、`SMAppService` 登录启动稳定可用
- [ ] Homebrew Cask（`brew install --cask quick-thoughts`）
- [ ] GitHub Actions CI：每次打 tag 自动 build / 签名 / 发 Release
- [ ] 标签 / 简单 Markdown 高亮
- [ ] 导出 / 一键备份成 zip

## 🛠️ 开发

```bash
make build      # swift build (debug)
make test       # swift test —— 目前 16 个用例覆盖数据层
make run        # swift run（终端阻塞，关闭终端 App 也会跟着挂）
make bundle     # 仅打包 .app 到 dist/
make uninstall  # 删除已安装的 .app
make clean      # 清理 .build / dist
```

### 项目结构

```
Sources/QuickThoughts/
├── QuickThoughtsApp.swift                 入口；MenuBarExtra + Window + Settings
├── Models/Thought.swift                   数据模型
├── Storage/
│   ├── JSONFileRepository.swift           原子写、损坏备份、schema 守卫
│   └── ThoughtStore.swift                 ObservableObject + CRUD + 防抖落盘
├── Features/
│   ├── MenuBarContent.swift               菜单栏菜单
│   ├── Capture/                           捕捉弹窗（NSPanel + NSTextView 桥接）
│   └── Browse/                            主面板 + 卡片行
├── Localization/                          中英双语（Auto / English / 中文）
└── Settings/                              快捷键 Recorder + 登录启动
```

依赖只一个：[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) —— 全局快捷键注册 + SwiftUI Recorder 组件。

### 测试覆盖

```
ThoughtTests              Codable 往返
JSONFileRepositoryTests   读写 / 缺文件 / 损坏文件 / 高 schema 版本 / 嵌套目录
ThoughtStoreTests         CRUD / 空白裁剪 / 搜索 / 排序 / 落盘 / fatalLoadError
```

UI 层不做单测，依赖手工冒烟。新加 UI 行为请在 PR 描述里附 before/after 截图。

## 🤝 Contributing

欢迎 Issue 和 PR。提交前请确认：

1. `make test` 全部通过
2. `make build` 无新增警告
3. 改动尽量外科手术式 —— 不顺手"改善"无关代码
4. UI 改动附 before/after 截图
5. commit 信息小写动词起头（`feat:` / `fix:` / `style:` / `chore:` 等）

## 📄 License

[MIT](LICENSE) © 2026 ruanwenjun

## 🙏 Acknowledgements

- [Sindre Sorhus](https://github.com/sindresorhus) 的 [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) 让全局快捷键 + 录制 UI 几乎零代码就能用
- macOS 原生 `MenuBarExtra` / `NSPanel` / `Settings` scene 提供了菜单栏 App 的基础设施
