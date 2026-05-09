import SwiftUI
import AppKit

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var capture: CaptureWindowController

    var body: some View {
        Button("新建想法") { capture.show() }
        Button("打开面板") { openWindow(id: "main") }
        Divider()
        Button("设置...") {
            NSApp.activate(ignoringOtherApps: true)
            if #available(macOS 14, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        }
        .keyboardShortcut(",")
        Divider()
        Button("退出") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
