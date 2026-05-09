import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleCapture = Self(
        "toggleCapture",
        default: .init(.t, modifiers: [.command, .option])
    )
}
