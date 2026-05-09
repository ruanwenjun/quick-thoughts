import SwiftUI
import AppKit

@main
struct QuickThoughtsApp: App {
    @StateObject private var store: ThoughtStore

    init() {
        NSApp.setActivationPolicy(.accessory)

        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dataURL = appSupport
            .appendingPathComponent("QuickThoughts", isDirectory: true)
            .appendingPathComponent("thoughts.json")
        let repo = JSONFileRepository(fileURL: dataURL)
        _store = StateObject(wrappedValue: ThoughtStore(repo: repo))

        // SwiftUI may auto-instantiate the "main" Window at launch even for an accessory app.
        // Hide it on the next runloop tick so we start clean — user reopens via menu.
        DispatchQueue.main.async {
            for w in NSApp.windows where w.identifier?.rawValue == "main" {
                w.orderOut(nil)
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("Quick Thoughts", systemImage: "bubble.left.and.text.bubble.right") {
            MenuBarContent()
        }

        Window("Quick Thoughts", id: "main") {
            MainPanelView(store: store)
        }
        .defaultSize(width: 720, height: 560)
        .windowResizability(.contentMinSize)
    }
}
