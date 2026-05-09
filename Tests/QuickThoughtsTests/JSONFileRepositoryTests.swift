import XCTest
@testable import QuickThoughts

final class JSONFileRepositoryTests: XCTestCase {
    var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("QuickThoughtsTests-\(UUID())")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func testSaveLoadRoundtrip() throws {
        let url = tempDir.appendingPathComponent("thoughts.json")
        let repo = JSONFileRepository(fileURL: url)
        let original = [
            Thought(id: UUID(), content: "first", createdAt: Date(timeIntervalSince1970: 100), updatedAt: Date(timeIntervalSince1970: 100)),
            Thought(id: UUID(), content: "second\nline", createdAt: Date(timeIntervalSince1970: 200), updatedAt: Date(timeIntervalSince1970: 200)),
        ]
        try repo.save(original)
        let loaded = try repo.load()
        XCTAssertEqual(loaded, original)
    }

    func testLoadNonExistentReturnsEmpty() throws {
        let url = tempDir.appendingPathComponent("missing.json")
        let repo = JSONFileRepository(fileURL: url)
        XCTAssertEqual(try repo.load(), [])
    }

    func testLoadCorruptFileBacksUpAndReturnsEmpty() throws {
        let url = tempDir.appendingPathComponent("thoughts.json")
        try "not valid json {".write(to: url, atomically: true, encoding: .utf8)
        let repo = JSONFileRepository(fileURL: url)
        XCTAssertEqual(try repo.load(), [])
        let dirContents = try FileManager.default.contentsOfDirectory(atPath: tempDir.path)
        XCTAssertTrue(dirContents.contains { $0.contains("corrupt-") },
                      "expected a backup file with 'corrupt-' in name, found: \(dirContents)")
    }

    func testRejectsHigherSchemaVersion() throws {
        let url = tempDir.appendingPathComponent("thoughts.json")
        let json = #"{"schemaVersion": 99, "thoughts": []}"#
        try json.write(to: url, atomically: true, encoding: .utf8)
        let repo = JSONFileRepository(fileURL: url)
        XCTAssertThrowsError(try repo.load()) { error in
            guard case JSONFileRepository.RepoError.unsupportedSchemaVersion = error else {
                XCTFail("expected unsupportedSchemaVersion, got \(error)")
                return
            }
        }
    }

    func testSaveCreatesParentDirectoryIfMissing() throws {
        let url = tempDir.appendingPathComponent("nested/deep/thoughts.json")
        let repo = JSONFileRepository(fileURL: url)
        try repo.save([])
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
