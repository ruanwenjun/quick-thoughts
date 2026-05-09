import SwiftUI
import AppKit
import KeyboardShortcuts

@main
struct QuickThoughtsApp: App {
    @StateObject private var store: ThoughtStore
    @StateObject private var capture: CaptureWindowController
    private let dataFileURL: URL

    init() {
        NSApp.setActivationPolicy(.accessory)

        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dataURL = appSupport
            .appendingPathComponent("QuickThoughts", isDirectory: true)
            .appendingPathComponent("thoughts.json")
        self.dataFileURL = dataURL

        let repo = JSONFileRepository(fileURL: dataURL)
        let store = ThoughtStore(repo: repo)
        let capture = CaptureWindowController(store: store)
        _store = StateObject(wrappedValue: store)
        _capture = StateObject(wrappedValue: capture)

        KeyboardShortcuts.onKeyDown(for: .toggleCapture) { [capture] in
            Task { @MainActor in capture.toggle() }
        }

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

        Settings {
            SettingsView(dataFileURL: dataFileURL)
        }
    }
}
