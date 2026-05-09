import AppKit
import SwiftUI
import Combine

@MainActor
final class CaptureWindowController: NSObject, NSWindowDelegate, ObservableObject {
    @Published var draft: String = ""

    private let store: ThoughtStore
    private var panel: NSPanel?

    init(store: ThoughtStore) {
        self.store = store
    }

    func toggle() {
        if let p = panel, p.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        let panel = ensurePanel()
        positionPanelOnActiveScreen(panel)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func ensurePanel() -> NSPanel {
        if let p = panel { return p }

        let p = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 160),
            styleMask: [.titled, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        p.titleVisibility = .hidden
        p.titlebarAppearsTransparent = true
        p.isMovableByWindowBackground = true
        p.level = .floating
        p.isReleasedWhenClosed = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.hidesOnDeactivate = false
        p.delegate = self
        p.standardWindowButton(.closeButton)?.isHidden = true
        p.standardWindowButton(.miniaturizeButton)?.isHidden = true
        p.standardWindowButton(.zoomButton)?.isHidden = true

        let host = NSHostingView(
            rootView: CaptureView(
                store: store,
                draft: Binding(get: { [weak self] in self?.draft ?? "" },
                               set: { [weak self] in self?.draft = $0 }),
                onClose: { [weak self] in self?.hide() }
            )
        )
        host.translatesAutoresizingMaskIntoConstraints = false
        p.contentView = host
        self.panel = p
        return p
    }

    private func positionPanelOnActiveScreen(_ panel: NSPanel) {
        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let screen = screen else { return }
        let frame = screen.visibleFrame
        let panelSize = panel.frame.size
        let x = frame.midX - panelSize.width / 2
        let y = frame.minY + frame.height * 2 / 3 - panelSize.height / 2
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // NSWindowDelegate: when user clicks outside / panel resigns key, hide it (draft is preserved)
    func windowDidResignKey(_ notification: Notification) {
        hide()
    }
}
