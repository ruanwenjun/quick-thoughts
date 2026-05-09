import SwiftUI

struct MainPanelView: View {
    @ObservedObject var store: ThoughtStore
    @State private var query: String = ""

    private var filtered: [Thought] {
        store.search(query)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let err = store.fatalLoadError {
                errorView(err)
            } else if store.thoughts.isEmpty {
                emptyView
            } else if filtered.isEmpty {
                noMatchesView
            } else {
                List(filtered) { thought in
                    ThoughtRowView(thought: thought)
                }
                .listStyle(.inset)
            }

            Divider()
            HStack {
                Text(footerText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(minWidth: 480, minHeight: 360)
        .searchable(text: $query, placement: .toolbar, prompt: "搜索想法")
    }

    private var footerText: String {
        if query.isEmpty {
            return "共 \(store.thoughts.count) 条想法"
        } else {
            return "找到 \(filtered.count) / \(store.thoughts.count) 条"
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("还没有想法").font(.headline)
            Text("按下 ⌥⌘T 记录第一条想法")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noMatchesView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("没有匹配的想法").font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
