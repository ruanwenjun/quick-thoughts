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
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filtered) { thought in
                            ThoughtRowView(thought: thought, store: store)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }

            Divider().opacity(0.4)
            HStack {
                Text(footerText)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
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
