import SwiftUI
import AppKit

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("打开面板") { openWindow(id: "main") }
        Divider()
        Button("退出") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
