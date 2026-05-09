import SwiftUI

@main
struct QuickThoughtsApp: App {
    init() {
        NSApp.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("Quick Thoughts", systemImage: "bubble.left.and.text.bubble.right") {
            Button("退出") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        }
    }
}
