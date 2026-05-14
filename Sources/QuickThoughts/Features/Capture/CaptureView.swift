import SwiftUI

struct CaptureView: View {
    @EnvironmentObject private var localizer: Localizer
    @ObservedObject var store: ThoughtStore
    @ObservedObject var capture: CaptureWindowController
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                CaptureTextEditor(
                    text: $capture.draft,
                    onSubmit: submit,
                    onCancel: cancel
                )
                .frame(minHeight: 96, idealHeight: 128, maxHeight: 400)

                if capture.draft.isEmpty {
                    Text(localizer.t(.capturePlaceholder))
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 22)
                        .padding(.top, 18)
                        .allowsHitTesting(false)
                }
            }

            Divider().opacity(0.4)
            HStack(spacing: 14) {
                Spacer()
                hint("⇧↵", localizer.t(.captureHintNewline))
                hint("↵", localizer.t(.captureHintSave))
                hint("esc", localizer.t(.captureHintCancel))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(.thinMaterial)
        .frame(width: 560)
    }

    private func hint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(key)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                )
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
    }

    private func submit() {
        store.add(capture.draft)
        capture.draft = ""
        onClose()
    }

    private func cancel() {
        // do not save; preserve draft for next open
        onClose()
    }
}
