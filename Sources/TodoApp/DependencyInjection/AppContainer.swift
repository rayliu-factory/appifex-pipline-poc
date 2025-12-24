import Factory
import Foundation

public final class AppContainer: SharedContainer {
    public static let shared = AppContainer()

    public let manager = ContainerManager()

    private init() { }
}

extension AppContainer {
    public var todoRepository: Factory<TodoRepository> {
        self { InMemoryTodoRepository(initialTodos: Self.mockTodos) }
            .scope(.singleton)
    }

    public var uuidGenerator: Factory<() -> UUID> {
        self { UUID.init }
    }

    public var dateGenerator: Factory<() -> Date> {
        self { Date.init }
    }
}

extension AppContainer {
    static let mockTodos: [Todo] = [
        Todo(
            title: "Build iOS App",
            description: "Create a todo app using TCA",
            isCompleted: false
        ),
        Todo(
            title: "Learn Swift Navigation",
            description: "Understand navigation patterns",
            isCompleted: true,
            completedAt: Date()
        ),
        Todo(
            title: "Set up Factory DI",
            description: "Configure dependency injection",
            isCompleted: true,
            completedAt: Date()
        ),
    ]
}
