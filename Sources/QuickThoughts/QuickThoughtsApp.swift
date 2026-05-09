import SwiftUI
import AppKit

@main
struct QuickThoughtsApp: App {
    @StateObject private var store: ThoughtStore
    @StateObject private var capture: CaptureWindowController

    init() {
        NSApp.setActivationPolicy(.accessory)

        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dataURL = appSupport
            .appendingPathComponent("QuickThoughts", isDirectory: true)
            .appendingPathComponent("thoughts.json")
        let repo = JSONFileRepository(fileURL: dataURL)
        let store = ThoughtStore(repo: repo)
        _store = StateObject(wrappedValue: store)
        _capture = StateObject(wrappedValue: CaptureWindowController(store: store))

        DispatchQueue.main.async {
            for w in NSApp.windows where w.identifier?.rawValue == "main" {
                w.orderOut(nil)
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("Quick Thoughts", systemImage: "bubble.left.and.text.bubble.right") {
            MenuBarContent(capture: capture)
        }

        Window("Quick Thoughts", id: "main") {
            MainPanelView(store: store)
        }
        .defaultSize(width: 720, height: 560)
        .windowResizability(.contentMinSize)
    }
}
