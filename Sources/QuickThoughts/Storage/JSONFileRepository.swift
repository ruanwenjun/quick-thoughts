import Foundation

struct JSONFileRepository {
    enum RepoError: Error {
        case unsupportedSchemaVersion(Int)
    }

    private struct DiskFormat: Codable {
        var schemaVersion: Int
        var thoughts: [Thought]
    }

    static let currentSchemaVersion = 1

    let fileURL: URL

    func load() throws -> [Thought] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let parsed: DiskFormat
        do {
            parsed = try decoder.decode(DiskFormat.self, from: data)
        } catch {
            try? backupCorruptFile()
            return []
        }
        if parsed.schemaVersion > Self.currentSchemaVersion {
            throw RepoError.unsupportedSchemaVersion(parsed.schemaVersion)
        }
        return parsed.thoughts
    }

    func save(_ thoughts: [Thought]) throws {
        let parent = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let payload = DiskFormat(schemaVersion: Self.currentSchemaVersion, thoughts: thoughts)
        let data = try encoder.encode(payload)

        let tmp = fileURL.appendingPathExtension("tmp")
        defer { try? FileManager.default.removeItem(at: tmp) }
        try data.write(to: tmp, options: .atomic)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            _ = try FileManager.default.replaceItemAt(fileURL, withItemAt: tmp)
        } else {
            try FileManager.default.moveItem(at: tmp, to: fileURL)
        }
    }

    private func backupCorruptFile() throws {
        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let suffix = UUID().uuidString.prefix(8)
        let parent = fileURL.deletingLastPathComponent()
        let backupName = fileURL.lastPathComponent + ".corrupt-\(stamp)-\(suffix)"
        let backup = parent.appendingPathComponent(backupName)
        try FileManager.default.moveItem(at: fileURL, to: backup)
    }
}
