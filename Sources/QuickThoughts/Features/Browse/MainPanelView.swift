import SwiftUI

struct MainPanelView: View {
    @EnvironmentObject private var localizer: Localizer
    @ObservedObject var store: ThoughtStore
    @State private var query: String = ""

    private var filtered: [Thought] {
        store.search(query)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let err = store.fatalLoadError {
                errorView(localizer.t(err))
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
        .searchable(text: $query, placement: .toolbar, prompt: localizer.t(.mainSearchPrompt))
    }

    private var footerText: String {
        if query.isEmpty {
            return localizer.t(.mainCountTotal(store.thoughts.count))
        } else {
            return localizer.t(.mainCountFiltered(filtered.count, store.thoughts.count))
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(localizer.t(.mainEmptyTitle)).font(.headline)
            Text(localizer.t(.mainEmptyHint))
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
            Text(localizer.t(.mainNoMatches)).font(.headline)
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
