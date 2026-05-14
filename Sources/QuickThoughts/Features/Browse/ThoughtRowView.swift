import SwiftUI

struct ThoughtRowView: View {
    let thought: Thought
    @ObservedObject var store: ThoughtStore

    @EnvironmentObject private var localizer: Localizer
    @Environment(\.colorScheme) private var colorScheme
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(Self.relativeFormatter.localizedString(for: thought.createdAt, relativeTo: Date()))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .help(Self.absoluteFormatter.string(from: thought.createdAt))
                Spacer(minLength: 0)
                if isHovering && !isEditing && !pendingDelete {
                    actionIcons.transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }

            if isEditing {
                editor
            } else if pendingDelete {
                deleteConfirmation
            } else {
                Text(thought.content)
                    .font(.system(size: 14))
                    .lineSpacing(3)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: cardShadow, radius: isHovering ? 6 : 2, x: 0, y: isHovering ? 2 : 1)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
        .animation(.easeInOut(duration: 0.15), value: pendingDelete)
        .onHover { isHovering = $0 }
    }

    // MARK: - Card style

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(cardFillColor)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .strokeBorder(cardStrokeColor, lineWidth: 0.5)
    }

    private var cardFillColor: Color {
        if pendingDelete {
            return Color.red.opacity(colorScheme == .dark ? 0.15 : 0.08)
        }
        if colorScheme == .dark {
            return isHovering ? Color.white.opacity(0.07) : Color.white.opacity(0.04)
        } else {
            return isHovering ? Color.white : Color.white.opacity(0.85)
        }
    }

    private var cardStrokeColor: Color {
        if pendingDelete {
            return Color.red.opacity(0.3)
        }
        return colorScheme == .dark
            ? Color.white.opacity(isHovering ? 0.10 : 0.06)
            : Color.black.opacity(isHovering ? 0.10 : 0.06)
    }

    private var cardShadow: Color {
        colorScheme == .dark
            ? Color.black.opacity(isHovering ? 0.35 : 0.20)
            : Color.black.opacity(isHovering ? 0.08 : 0.04)
    }

    // MARK: - Action icons

    private var actionIcons: some View {
        HStack(spacing: 4) {
            iconButton(systemName: "pencil", help: localizer.t(.rowEditTooltip)) {
                editDraft = thought.content
                isEditing = true
            }
            iconButton(systemName: "trash", help: localizer.t(.rowDeleteTooltip), tint: .red) {
                pendingDelete = true
            }
        }
    }

    private func iconButton(systemName: String, help: String, tint: Color = .secondary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
        .help(help)
    }

    // MARK: - Editor

    private var editor: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TextEditor(text: $editDraft)
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 60)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                )
            HStack(spacing: 8) {
                Button(localizer.t(.rowCancel)) {
                    isEditing = false
                    editDraft = ""
                }
                .keyboardShortcut(.cancelAction)
                Button(localizer.t(.rowSave)) {
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

    // MARK: - Delete confirmation

    private var deleteConfirmation: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 12))
            Text(localizer.t(.rowConfirmDelete))
                .font(.system(size: 13))
                .foregroundStyle(.red)
            Spacer()
            Button(localizer.t(.rowCancel)) { pendingDelete = false }
                .buttonStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )
            Button(localizer.t(.rowDelete)) {
                store.delete(id: thought.id)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.red)
            )
        }
    }
}
