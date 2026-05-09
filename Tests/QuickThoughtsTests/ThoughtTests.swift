import XCTest
@testable import QuickThoughts

final class ThoughtTests: XCTestCase {
    func testCodableRoundtripPreservesAllFields() throws {
        let original = Thought(
            id: UUID(),
            content: "Test thought\nwith newline",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_100)
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Thought.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }
}
