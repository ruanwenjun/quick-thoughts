import XCTest
@testable import QuickThoughts

final class ThoughtStoreTests: XCTestCase {
    var tempDir: URL!
    var fileURL: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("QuickThoughtsStoreTests-\(UUID())")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        fileURL = tempDir.appendingPathComponent("thoughts.json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    private func makeStore() -> ThoughtStore {
        ThoughtStore(repo: JSONFileRepository(fileURL: fileURL))
    }

    func testAddInsertsAtFront() {
        let store = makeStore()
        store.add("first")
        store.add("second")
        XCTAssertEqual(store.thoughts.map { $0.content }, ["second", "first"])
    }

    func testAddIgnoresEmptyOrWhitespaceContent() {
        let store = makeStore()
        store.add("")
        store.add("   \n  ")
        XCTAssertTrue(store.thoughts.isEmpty)
    }

    func testAddTrimsLeadingAndTrailingWhitespace() {
        let store = makeStore()
        store.add("  hello world  \n")
        XCTAssertEqual(store.thoughts.first?.content, "hello world")
    }

    func testUpdateChangesContentAndUpdatedAt() {
        let store = makeStore()
        store.add("original")
        let id = store.thoughts[0].id
        let originalUpdatedAt = store.thoughts[0].updatedAt

        Thread.sleep(forTimeInterval: 0.01)
        store.update(id: id, content: "edited")

        XCTAssertEqual(store.thoughts[0].content, "edited")
        XCTAssertGreaterThan(store.thoughts[0].updatedAt, originalUpdatedAt)
    }

    func testDeleteRemovesById() {
        let store = makeStore()
        store.add("a")
        store.add("b")
        let idToDelete = store.thoughts[0].id
        store.delete(id: idToDelete)
        XCTAssertEqual(store.thoughts.count, 1)
        XCTAssertNotEqual(store.thoughts[0].id, idToDelete)
    }

    func testSearchIsCaseInsensitive() {
        let store = makeStore()
        store.add("Hello World")
        store.add("foo bar")
        XCTAssertEqual(store.search("HELLO").map { $0.content }, ["Hello World"])
        XCTAssertEqual(store.search("BAR").map { $0.content }, ["foo bar"])
        XCTAssertEqual(store.search("").count, 2)
    }

    func testFlushPersistsToDisk() throws {
        let store = makeStore()
        store.add("persisted")
        store.flush()

        let raw = try String(contentsOf: fileURL)
        XCTAssertTrue(raw.contains("persisted"))

        // Re-load via a new store, verify
        let store2 = makeStore()
        XCTAssertEqual(store2.thoughts.map { $0.content }, ["persisted"])
    }

    func testLoadOnInitSortsByCreatedAtDescending() throws {
        // Pre-populate file with two thoughts in ascending order
        let early = Thought(id: UUID(), content: "early", createdAt: Date(timeIntervalSince1970: 100), updatedAt: Date(timeIntervalSince1970: 100))
        let late = Thought(id: UUID(), content: "late", createdAt: Date(timeIntervalSince1970: 200), updatedAt: Date(timeIntervalSince1970: 200))
        try JSONFileRepository(fileURL: fileURL).save([early, late])

        let store = makeStore()
        XCTAssertEqual(store.thoughts.map { $0.content }, ["late", "early"])
    }

    func testFatalLoadErrorOnHigherSchemaVersion() throws {
        let json = #"{"schemaVersion": 99, "thoughts": []}"#
        try json.write(to: fileURL, atomically: true, encoding: .utf8)
        let store = makeStore()
        XCTAssertNotNil(store.fatalLoadError)
    }
}
