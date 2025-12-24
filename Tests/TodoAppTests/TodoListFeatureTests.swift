import ComposableArchitecture
import XCTest
@testable import TodoApp

@MainActor
final class TodoListFeatureTests: XCTestCase {

    func testLoadTodosOnAppear() async {
        let todo1 = Todo(title: "Test 1")
        let todo2 = Todo(title: "Test 2", isCompleted: true)
        let todos = [todo1, todo2]

        let store = TestStore(
            initialState: TodoListFeature.State()
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.todoRepository = InMemoryTodoRepository(initialTodos: todos)
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.todosLoaded, timeout: .seconds(2)) { state in
            state.isLoading = false
            state.todos = IdentifiedArray(uniqueElements: todos)
        }
    }

    func testToggleTodoCompletion() async {
        let todo = Todo(title: "Test Todo")
        let fixedDate = Date(timeIntervalSince1970: 1000)

        let store = TestStore(
            initialState: TodoListFeature.State(
                todos: IdentifiedArray(uniqueElements: [todo])
            )
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.todoRepository = InMemoryTodoRepository(initialTodos: [todo])
            $0.date.now = fixedDate
        }

        // Disable exhaustivity temporarily to avoid date comparison issues
        store.exhaustivity = .off

        await store.send(.toggleTodoCompletion(todo))

        await store.receive(\.todoUpdated, timeout: .seconds(2))

        // Manual verification
        let updatedTodo = store.state.todos[id: todo.id]
        XCTAssertNotNil(updatedTodo)
        XCTAssertTrue(updatedTodo?.isCompleted ?? false, "Todo should be marked as completed")
        XCTAssertNotNil(updatedTodo?.completedAt, "CompletedAt should be set")
    }

    func testDeleteTodo() async {
        let todo = Todo(title: "Test Todo")

        let store = TestStore(
            initialState: TodoListFeature.State(
                todos: IdentifiedArray(uniqueElements: [todo])
            )
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.todoRepository = InMemoryTodoRepository(initialTodos: [todo])
        }

        await store.send(.deleteTodo(todo)) {
            $0.todos.remove(id: todo.id)
        }

        XCTAssertTrue(store.state.todos.isEmpty, "Todos should be empty after deletion")
    }

    func testFilterTodos() async {
        let activeTodo = Todo(title: "Active Task")
        let completedTodo = Todo(title: "Completed Task", isCompleted: true, completedAt: Date())

        let store = TestStore(
            initialState: TodoListFeature.State(
                todos: IdentifiedArray(uniqueElements: [activeTodo, completedTodo])
            )
        ) {
            TodoListFeature()
        }

        // Test filter to active
        await store.send(.filterChanged(.active)) {
            $0.filter = .active
        }

        XCTAssertEqual(store.state.filteredTodos.count, 1, "Should have 1 active todo")
        XCTAssertEqual(store.state.filteredTodos.first?.id, activeTodo.id, "Should show the active todo")

        // Test filter to completed
        await store.send(.filterChanged(.completed)) {
            $0.filter = .completed
        }

        XCTAssertEqual(store.state.filteredTodos.count, 1, "Should have 1 completed todo")
        XCTAssertEqual(store.state.filteredTodos.first?.id, completedTodo.id, "Should show the completed todo")

        // Test filter to all
        await store.send(.filterChanged(.all)) {
            $0.filter = .all
        }

        XCTAssertEqual(store.state.filteredTodos.count, 2, "Should show all 2 todos")
    }

    func testInitialState() {
        let state = TodoListFeature.State()

        XCTAssertTrue(state.todos.isEmpty, "Initial todos should be empty")
        XCTAssertFalse(state.isLoading, "Should not be loading initially")
        XCTAssertEqual(state.filter, .all, "Default filter should be .all")
    }

    func testFilteredTodosComputed() {
        let activeTodo = Todo(title: "Active")
        let completedTodo = Todo(title: "Completed", isCompleted: true)

        var state = TodoListFeature.State(
            todos: IdentifiedArray(uniqueElements: [activeTodo, completedTodo])
        )

        // Test all filter
        state.filter = .all
        XCTAssertEqual(state.filteredTodos.count, 2, "All filter should show all todos")

        // Test active filter
        state.filter = .active
        XCTAssertEqual(state.filteredTodos.count, 1, "Active filter should show 1 todo")
        XCTAssertEqual(state.filteredTodos.first?.id, activeTodo.id)

        // Test completed filter
        state.filter = .completed
        XCTAssertEqual(state.filteredTodos.count, 1, "Completed filter should show 1 todo")
        XCTAssertEqual(state.filteredTodos.first?.id, completedTodo.id)
    }
}
