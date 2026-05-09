# Quick Thoughts

一个常驻菜单栏的 macOS 小工具，用于**快速捕捉一闪而过的想法**。

按下全局快捷键，弹窗输入，回车保存；用菜单栏图标打开主面板浏览、搜索、编辑、删除所有已记录的想法。数据以 JSON 持久化在本地。

## 系统要求

- macOS 13 或更新
- Xcode Command Line Tools（开发或源码安装时需要）：
  ```bash
  xcode-select --install
  ```

## 安装

### 方式 A：从 Release 下载（推荐普通用户）

> 待发布。GitHub Releases 上传后会有 `Quick-Thoughts-*.zip`，下载解压，把 `Quick Thoughts.app` 拖到 `/Applications`。

首次启动 macOS 会因为未签名而弹"无法验证开发者"警告：

1. **右键 / Control-点击** `Quick Thoughts.app`
2. 选 **打开**
3. 在弹窗里再次点 **打开**

之后双击启动就没有警告。

### 方式 B：源码安装（推荐开发者 / 当前用户）

```bash
git clone https://github.com/<your-user>/quick-thoughts.git
cd quick-thoughts
make install        # 装到 /Applications，需要输 sudo 密码
# 或者：
make install-user   # 装到 ~/Applications，免 sudo
```

`make install` 会自动 `swift build -c release`、生成 `.app` 包、ad-hoc 签名、拷到 `/Applications`。

## 使用

| 操作 | 快捷键 |
| --- | --- |
| 唤起捕捉弹窗 | `⌥⌘T`（可在设置里改） |
| 弹窗内换行 | `Shift+Enter` |
| 弹窗内保存 | `Enter` |
| 弹窗内取消（保留草稿） | `Esc` |
| 打开 / 关闭设置 | `⌘,` |

菜单栏的小图标点开能看到："新建想法"、"打开面板"、"设置..."、"退出"。
主面板里悬停每条想法会浮出**编辑**和**删除**按钮，编辑是行内编辑、删除会先弹一次行内确认。

数据存放路径（设置里也能看到 + 一键 Finder 跳转）：

```
~/Library/Application Support/QuickThoughts/thoughts.json
```

JSON 格式简单稳定，可以手工备份、grep、迁移：

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

## 开机启动

在「系统设置 → 通用 → 登录项」把 `Quick Thoughts` 加进去，或者在 App 自己的设置里勾选"登录时启动"（**注意**：这个开关需要 App 已经被代码签名才能稳定工作；当前 ad-hoc 签名版本可能会失败 —— 系统设置加登录项更可靠）。

## 开发

```bash
git clone https://github.com/<your-user>/quick-thoughts.git
cd quick-thoughts
make build       # swift build (debug)
make test        # swift test，目前 16 个用例
make run         # swift run，终端里跑（关掉终端 App 也会挂）
make bundle      # 仅打包，不安装
make uninstall   # 删掉已安装的 .app
make clean       # 清掉 .build / dist
```

项目分层：

```
Sources/QuickThoughts/
├── QuickThoughtsApp.swift                  入口；MenuBarExtra + Window + Settings
├── Models/Thought.swift                    数据模型
├── Storage/
│   ├── JSONFileRepository.swift            原子写、损坏备份、schema 守卫
│   └── ThoughtStore.swift                  ObservableObject + CRUD + 防抖落盘
├── Features/
│   ├── MenuBarContent.swift                菜单栏菜单
│   ├── Capture/
│   │   ├── CaptureTextEditor.swift         NSTextView wrapper（Enter/Shift+Enter/ESC）
│   │   ├── CaptureView.swift               弹窗 SwiftUI body
│   │   └── CaptureWindowController.swift   管理 NSPanel
│   └── Browse/
│       ├── MainPanelView.swift             列表 + 搜索 + 状态分支
│       └── ThoughtRowView.swift            卡片样式行：编辑、删除、悬停浮出
└── Settings/
    ├── KeyboardShortcutsConfig.swift       .toggleCapture（默认 ⌥⌘T）
    └── SettingsView.swift                  Recorder + 登录启动 + 数据路径
```

依赖只一个：[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) —— 提供全局快捷键注册和录制 UI。

## License

MIT。详情见 [LICENSE](LICENSE)。
