import Foundation
import Combine
import AppKit

final class ThoughtStore: ObservableObject {
    @Published private(set) var thoughts: [Thought] = []
    @Published private(set) var fatalLoadError: String?
    @Published private(set) var lastSaveError: String?

    private let repo: JSONFileRepository
    private let saveSubject = PassthroughSubject<Void, Never>()
    private var saveCancellable: AnyCancellable?
    private var terminationObserver: NSObjectProtocol?

    init(repo: JSONFileRepository, debounceMilliseconds: Int = 500) {
        self.repo = repo
        loadInitial()

        saveCancellable = saveSubject
            .debounce(for: .milliseconds(debounceMilliseconds), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.flush() }

        terminationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.flush() }
    }

    deinit {
        if let obs = terminationObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    // MARK: - Loading

    private func loadInitial() {
        do {
            let loaded = try repo.load()
            self.thoughts = loaded.sorted { $0.createdAt > $1.createdAt }
        } catch JSONFileRepository.RepoError.unsupportedSchemaVersion(let v) {
            self.fatalLoadError = "数据由更新版 App (schema v\(v)) 写入，请升级 Quick Thoughts 后再试。"
        } catch {
            self.fatalLoadError = "无法加载数据：\(error.localizedDescription)"
        }
    }

    // MARK: - Mutations

    func add(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        let t = Thought(id: UUID(), content: trimmed, createdAt: now, updatedAt: now)
        thoughts.insert(t, at: 0)
        saveSubject.send()
    }

    func update(id: UUID, content: String) {
        guard let idx = thoughts.firstIndex(where: { $0.id == id }) else { return }
        thoughts[idx].content = content
        thoughts[idx].updatedAt = Date()
        saveSubject.send()
    }

    func delete(id: UUID) {
        thoughts.removeAll { $0.id == id }
        saveSubject.send()
    }

    // MARK: - Read

    func search(_ query: String) -> [Thought] {
        guard !query.isEmpty else { return thoughts }
        return thoughts.filter { $0.content.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Persistence

    func flush() {
        do {
            try repo.save(thoughts)
            lastSaveError = nil
        } catch {
            lastSaveError = error.localizedDescription
        }
    }
}
