import SwiftUI

struct CaptureView: View {
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
                    Text("记下一闪而过的想法…")
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 22)
                        .padding(.top, 18)
                        .allowsHitTesting(false)
                }
            }

            Divider().opacity(0.4)
            HStack(spacing: 0) {
                Spacer()
                Text("Shift+Enter 换行 · Enter 保存 · Esc 取消")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(.thinMaterial)
        .frame(width: 560)
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
