import Foundation

public struct Todo: Identifiable, Equatable, Codable {
    public let id: UUID
    public var title: String
    public var description: String
    public var isCompleted: Bool
    public var createdAt: Date
    public var completedAt: Date?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}

extension Todo {
    public static let mock = Todo(
        title: "Buy groceries",
        description: "Milk, eggs, bread"
    )

    public static let mockCompleted = Todo(
        title: "Finish project",
        description: "Complete the demo app",
        isCompleted: true,
        completedAt: Date()
    )
}
