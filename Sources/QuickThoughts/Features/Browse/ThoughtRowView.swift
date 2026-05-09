import SwiftUI

struct ThoughtRowView: View {
    let thought: Thought
    @ObservedObject var store: ThoughtStore

    @State private var isHovering = false
    @State private var isEditing = false
    @State private var editDraft: String = ""
    @State private var pendingDelete = false

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
            HStack {
                Text(Self.relativeFormatter.localizedString(for: thought.createdAt, relativeTo: Date()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .help(Self.absoluteFormatter.string(from: thought.createdAt))
                Spacer()
                if isHovering && !isEditing && !pendingDelete {
                    actionIcons
                }
            }

            if isEditing {
                editor
            } else if pendingDelete {
                deleteConfirmation
            } else {
                Text(thought.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(pendingDelete ? Color.red.opacity(0.08) : Color.clear)
        .cornerRadius(6)
        .onHover { isHovering = $0 }
    }

    private var actionIcons: some View {
        HStack(spacing: 8) {
            Button {
                editDraft = thought.content
                isEditing = true
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            .help("编辑")

            Button {
                pendingDelete = true
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
            .help("删除")
        }
    }

    private var editor: some View {
        VStack(alignment: .trailing, spacing: 6) {
            TextEditor(text: $editDraft)
                .font(.body)
                .frame(minHeight: 60)
                .border(Color.secondary.opacity(0.3))
            HStack(spacing: 8) {
                Button("取消") {
                    isEditing = false
                    editDraft = ""
                }
                .keyboardShortcut(.cancelAction)
                Button("保存") {
                    let trimmed = editDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    store.update(id: thought.id, content: trimmed)
                    isEditing = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(editDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var deleteConfirmation: some View {
        HStack {
            Text("确认删除这条想法？")
                .foregroundStyle(.red)
            Spacer()
            Button("取消") { pendingDelete = false }
            Button("删除", role: .destructive) {
                store.delete(id: thought.id)
            }
        }
    }
}
