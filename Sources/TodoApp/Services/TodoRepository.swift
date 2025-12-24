import Foundation

public protocol TodoRepository: Sendable {
    func fetchAll() async throws -> [Todo]
    func fetch(id: UUID) async throws -> Todo?
    func save(_ todo: Todo) async throws
    func delete(id: UUID) async throws
    func update(_ todo: Todo) async throws
}

public actor InMemoryTodoRepository: TodoRepository {
    private var todos: [UUID: Todo] = [:]

    public init(initialTodos: [Todo] = []) {
        self.todos = Dictionary(uniqueKeysWithValues: initialTodos.map { ($0.id, $0) })
    }

    public func fetchAll() async throws -> [Todo] {
        Array(todos.values).sorted { $0.createdAt > $1.createdAt }
    }

    public func fetch(id: UUID) async throws -> Todo? {
        todos[id]
    }

    public func save(_ todo: Todo) async throws {
        todos[todo.id] = todo
    }

    public func delete(id: UUID) async throws {
        todos.removeValue(forKey: id)
    }

    public func update(_ todo: Todo) async throws {
        guard todos[todo.id] != nil else {
            throw TodoRepositoryError.notFound
        }
        todos[todo.id] = todo
    }
}

public enum TodoRepositoryError: Error {
    case notFound
    case saveFailed
}
