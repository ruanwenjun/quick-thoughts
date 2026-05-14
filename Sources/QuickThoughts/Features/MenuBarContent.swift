import SwiftUI
import AppKit

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var localizer: Localizer
    @ObservedObject var capture: CaptureWindowController
    @ObservedObject var store: ThoughtStore

    var body: some View {
        if let err = store.lastSaveError {
            Text(localizer.t(.menuSaveErrorPrefix(err)))
                .font(.caption)
                .foregroundStyle(.red)
            Divider()
        }
        Button(localizer.t(.menuNewThought)) { capture.show() }
        Button(localizer.t(.menuOpenPanel)) {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "main")
        }
        Divider()
        if #available(macOS 14, *) {
            SettingsLink {
                Text(localizer.t(.menuSettings))
            }
            .keyboardShortcut(",")
        } else {
            Button(localizer.t(.menuSettings)) {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
            .keyboardShortcut(",")
        }
        Divider()
        Button(localizer.t(.menuQuit)) { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
