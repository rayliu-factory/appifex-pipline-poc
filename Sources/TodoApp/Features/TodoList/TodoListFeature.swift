import ComposableArchitecture
import Factory
import Foundation

@Reducer
public struct TodoListFeature {
    @ObservableState
    public struct State: Equatable {
        public var todos: IdentifiedArrayOf<Todo> = []
        public var isLoading = false
        public var filter: Filter = .all

        public enum Filter: String, CaseIterable, Equatable {
            case all = "All"
            case active = "Active"
            case completed = "Completed"
        }

        public var filteredTodos: IdentifiedArrayOf<Todo> {
            switch filter {
            case .all:
                return todos
            case .active:
                return todos.filter { !$0.isCompleted }
            case .completed:
                return todos.filter { $0.isCompleted }
            }
        }

        public init(
            todos: IdentifiedArrayOf<Todo> = [],
            isLoading: Bool = false,
            filter: Filter = .all
        ) {
            self.todos = todos
            self.isLoading = isLoading
            self.filter = filter
        }
    }

    public enum Action: Sendable {
        case onAppear
        case todosLoaded([Todo])
        case addTodoButtonTapped
        case todoTapped(Todo)
        case toggleTodoCompletion(Todo)
        case deleteTodo(Todo)
        case filterChanged(State.Filter)
        case todoUpdated(Todo)
    }

    @Dependency(\.todoRepository) var todoRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let todos = try await todoRepository.fetchAll()
                    await send(.todosLoaded(todos))
                }

            case let .todosLoaded(todos):
                state.isLoading = false
                state.todos = IdentifiedArray(uniqueElements: todos)
                return .none

            case .addTodoButtonTapped:
                return .none

            case .todoTapped:
                return .none

            case let .toggleTodoCompletion(todo):
                var updatedTodo = todo
                updatedTodo.isCompleted.toggle()
                updatedTodo.completedAt = updatedTodo.isCompleted ? Date() : nil

                return .run { send in
                    try await todoRepository.update(updatedTodo)
                    await send(.todoUpdated(updatedTodo))
                }

            case let .deleteTodo(todo):
                state.todos.remove(id: todo.id)
                return .run { _ in
                    try await todoRepository.delete(id: todo.id)
                }

            case let .filterChanged(filter):
                state.filter = filter
                return .none

            case let .todoUpdated(todo):
                state.todos[id: todo.id] = todo
                return .none
            }
        }
    }
}

extension DependencyValues {
    var todoRepository: TodoRepository {
        get { self[TodoRepositoryKey.self] }
        set { self[TodoRepositoryKey.self] = newValue }
    }

    private enum TodoRepositoryKey: DependencyKey {
        static let liveValue: TodoRepository = AppContainer.shared.todoRepository()
        static let testValue: TodoRepository = InMemoryTodoRepository()
    }
}
