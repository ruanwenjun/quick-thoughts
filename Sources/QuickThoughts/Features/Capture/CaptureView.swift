import SwiftUI

struct CaptureView: View {
    @ObservedObject var store: ThoughtStore
    @Binding var draft: String
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CaptureTextEditor(
                text: $draft,
                onSubmit: submit,
                onCancel: cancel
            )
            .frame(minHeight: 80, idealHeight: 120, maxHeight: 400)

            Divider()
            HStack(spacing: 8) {
                Spacer()
                Text("Shift+Enter 换行 · Enter 保存 · Esc 取消")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(.thinMaterial)
        .frame(width: 560)
    }

    private func submit() {
        store.add(draft)
        draft = ""
        onClose()
    }

    private func cancel() {
        // do not save; preserve draft for next open
        onClose()
    }
}
