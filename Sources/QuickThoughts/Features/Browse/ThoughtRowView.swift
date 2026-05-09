import SwiftUI

struct ThoughtRowView: View {
    let thought: Thought

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f
    }()

    private static let absoluteFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Self.relativeFormatter.localizedString(for: thought.createdAt, relativeTo: Date()))
                .font(.caption)
                .foregroundStyle(.secondary)
                .help(Self.absoluteFormatter.string(from: thought.createdAt))
            Text(thought.content)
                .font(.body)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 6)
    }
}
