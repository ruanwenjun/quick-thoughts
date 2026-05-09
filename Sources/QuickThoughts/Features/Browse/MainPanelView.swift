import SwiftUI

struct MainPanelView: View {
    @ObservedObject var store: ThoughtStore

    var body: some View {
        VStack(spacing: 0) {
            if let err = store.fatalLoadError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text(err)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.thoughts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.text.bubble.right")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("还没有想法")
                        .font(.headline)
                    Text("按下全局快捷键记录第一条想法")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.thoughts) { thought in
                    ThoughtRowView(thought: thought)
                }
                .listStyle(.inset)
            }

            Divider()
            HStack {
                Text("共 \(store.thoughts.count) 条想法")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(minWidth: 480, minHeight: 360)
    }
}
