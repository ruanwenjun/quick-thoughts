import Foundation

struct Thought: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var content: String
    let createdAt: Date
    var updatedAt: Date
}
