# Architecture Documentation

This document details the architecture patterns and implementation approach used in this Todo app demo.

## Table of Contents
1. [The Composable Architecture (TCA)](#the-composable-architecture-tca)
2. [Factory Dependency Injection](#factory-dependency-injection)
3. [Swift Navigation](#swift-navigation)
4. [Feature Organization](#feature-organization)
5. [Data Flow](#data-flow)

## The Composable Architecture (TCA)

TCA provides a unidirectional data flow architecture pattern for SwiftUI apps.

### Core Components

#### State
The single source of truth for a feature's data:

```swift
@ObservableState
public struct State {
    var todos: IdentifiedArrayOf<Todo> = []
    var isLoading = false
    var filter: Filter = .all
}
```

**Key Points:**
- Marked with `@ObservableState` for automatic change tracking
- All state is immutable and changes happen through reducers
- Use `IdentifiedArray` for collections that need efficient ID-based lookups

#### Actions
All possible events that can occur in a feature:

```swift
public enum Action: Sendable {
    case onAppear
    case todosLoaded([Todo])
    case toggleTodoCompletion(Todo)
    case deleteTodo(Todo)
}
```

**Key Points:**
- Must conform to `Sendable` for Swift 6 concurrency safety
- Include both user actions (button taps) and system actions (data loaded)
- Delegate actions allow parent features to react to child feature events

#### Reducer
Pure functions that evolve state in response to actions:

```swift
Reduce { state, action in
    switch action {
    case .toggleTodoCompletion(let todo):
        var updatedTodo = todo
        updatedTodo.isCompleted.toggle()

        return .run { send in
            try await todoRepository.update(updatedTodo)
            await send(.todoUpdated(updatedTodo))
        }
    }
}
```

**Key Points:**
- Reducers are pure functions: same inputs = same outputs
- Side effects are expressed as `Effect` values (using `.run { }`)
- Never mutate external state or perform I/O directly in reducers

### Effect Management

TCA uses structured concurrency for side effects:

```swift
return .run { send in
    let todos = try await todoRepository.fetchAll()
    await send(.todosLoaded(todos))
}
```

**Benefits:**
- Automatic cancellation when views disappear
- Type-safe effect composition
- Testable with dependency injection

## Factory Dependency Injection

Factory provides compile-time safe dependency injection.

### Container Setup

```swift
public final class AppContainer: SharedContainer {
    public static let shared = AppContainer()

    public var todoRepository: Factory<TodoRepository> {
        self { InMemoryTodoRepository(initialTodos: Self.mockTodos) }
            .scope(.singleton)
    }
}
```

**Key Features:**
- **Type Safety**: Dependencies are strongly typed
- **Scoping**: Singleton, cached, factory, and shared scopes
- **Testing**: Easy to override dependencies for tests
- **Lazy**: Dependencies created only when first accessed

### TCA Integration

Integrate Factory with TCA's dependency system:

```swift
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
```

Then use in reducers:

```swift
@Dependency(\.todoRepository) var todoRepository
```

## Swift Navigation

Swift Navigation provides declarative, state-driven navigation.

### Navigation State

Navigation destinations are part of your feature's state:

```swift
@ObservableState
public struct State {
    var todoList: TodoListFeature.State
    @Presents public var destination: Destination.State?
}

@Reducer
public enum Destination {
    case todoDetail(TodoDetailFeature)
    case todoForm(TodoFormFeature)
}
```

**Key Points:**
- `@Presents` property wrapper manages presentation state
- Destinations are modeled as an enum for type safety
- Navigation state is serializable (deep linking support)

### Navigation Actions

Trigger navigation by setting destination state:

```swift
case .todoList(.addTodoButtonTapped):
    state.destination = .todoForm(TodoFormFeature.State())
    return .none

case let .todoList(.todoTapped(todo)):
    state.destination = .todoDetail(TodoDetailFeature.State(todo: todo))
    return .none
```

### Navigation Views

Bind navigation state to SwiftUI views:

```swift
// Sheet presentation
.sheet(
    item: $store.scope(state: \.destination?.todoForm, action: \.destination.todoForm)
) { store in
    TodoFormView(store: store)
}

// NavigationStack destination
.navigationDestination(
    item: $store.scope(state: \.destination?.todoDetail, action: \.destination.todoDetail)
) { store in
    TodoDetailView(store: store)
}
```

## Feature Organization

Each feature is self-contained with its own:
- State (data model)
- Actions (events)
- Reducer (business logic)
- View (UI)

### Directory Structure

```
Features/
├── TodoList/
│   ├── TodoListFeature.swift    # State + Actions + Reducer
│   └── TodoListView.swift       # SwiftUI view
└── TodoDetail/
    ├── TodoDetailFeature.swift  # Detail reducer
    ├── TodoDetailView.swift     # Detail view
    ├── TodoFormFeature.swift    # Form reducer
    └── TodoFormView.swift       # Form view
```

### Parent-Child Communication

**Parent → Child**: Pass state down

```swift
Scope(state: \.todoList, action: \.todoList) {
    TodoListFeature()
}
```

**Child → Parent**: Delegate actions up

```swift
public enum Delegate: Sendable {
    case todoUpdated(Todo)
    case dismiss
}

// In parent reducer:
case let .destination(.presented(.todoForm(.delegate(.todoCreated(todo))))):
    state.todoList.todos.insert(todo, at: 0)
    return .none
```

## Data Flow

### Read Flow
1. User views screen
2. View renders based on `State`
3. `onAppear` sends action
4. Reducer handles action, triggers effect
5. Effect loads data from repository
6. Effect sends action with loaded data
7. Reducer updates state
8. View re-renders

### Write Flow
1. User taps button
2. View sends action
3. Reducer updates local state
4. Reducer triggers effect to persist
5. Effect calls repository
6. On success, effect confirms via action
7. Reducer finalizes state update
8. View re-renders

### Async/Await Integration

Modern Swift concurrency:

```swift
return .run { send in
    // Async work
    let result = try await someAsyncOperation()

    // Send result back to reducer
    await send(.operationCompleted(result))
}
```

### Testing

TCA's `TestStore` enables step-by-step state verification:

```swift
@Test
func testToggleTodoCompletion() async {
    let store = TestStore(
        initialState: TodoListFeature.State(todos: [.mock])
    ) {
        TodoListFeature()
    }

    // Send action
    await store.send(.toggleTodoCompletion(.mock))

    // Verify state change
    await store.receive(\.todoUpdated) {
        $0.todos[0].isCompleted = true
    }
}
```

## Best Practices

### 1. Keep Reducers Pure
- No side effects in reducers
- No direct API calls or database access
- Use `Effect` for all async work

### 2. Model Navigation as State
- Store navigation state in your reducer
- Use `@Presents` for optional destinations
- Handle dismissal via actions

### 3. Use Dependency Injection
- Inject all external dependencies
- Provide test doubles for testing
- Avoid global singletons (except DI container)

### 4. Compose Features
- Build small, focused features
- Compose them using parent reducers
- Use `Scope` for parent-child relationships

### 5. Leverage Swift Concurrency
- Use `async/await` in effects
- Mark actions as `Sendable`
- Let TCA handle cancellation

## Performance Considerations

### IdentifiedArray
Use `IdentifiedArray` for collections:
- O(1) lookups by ID
- Efficient updates
- Maintains order

### Scoped Stores
Scope stores to minimize re-renders:

```swift
TodoListView(
    store: store.scope(state: \.todoList, action: \.todoList)
)
```

### Effect Cancellation
Effects automatically cancel when views disappear:

```swift
return .run { send in
    // This cancels when the view is dismissed
    try await Task.sleep(for: .seconds(5))
    await send(.timerFired)
}
```

## Resources

- [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Factory DI](https://github.com/hmlongco/Factory)
- [Swift Navigation](https://github.com/pointfreeco/swift-navigation)
- [Point-Free Episodes](https://www.pointfree.co)
