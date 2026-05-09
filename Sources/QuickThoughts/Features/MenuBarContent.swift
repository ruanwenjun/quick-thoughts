import SwiftUI
import AppKit

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var capture: CaptureWindowController
    @ObservedObject var store: ThoughtStore

    var body: some View {
        if let err = store.lastSaveError {
            Text("⚠️ 保存失败：\(err)")
                .font(.caption)
                .foregroundStyle(.red)
            Divider()
        }
        Button("新建想法") { capture.show() }
        Button("打开面板") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "main")
        }
        Divider()
        if #available(macOS 14, *) {
            SettingsLink {
                Text("设置...")
            }
            .keyboardShortcut(",")
        } else {
            Button("设置...") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
            .keyboardShortcut(",")
        }
        Divider()
        Button("退出") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
