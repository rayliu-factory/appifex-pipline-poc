# Testing Guide

## Running Tests

### In Xcode
Press **`Cmd+U`** to run all tests.

Or:
- **Product > Test**
- Right-click a test class/method and select **Run**

### Via Command Line
```bash
# Run all tests
xcodebuild test -scheme TodoApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Structure

Tests are located in `Tests/TodoAppTests/` and use **XCTest**, Apple's standard testing framework.

### Current Tests

#### TodoListFeatureTests

1. **testLoadTodosOnAppear**
   - Verifies todos load when view appears
   - Tests async data fetching
   - Validates state transitions

2. **testToggleTodoCompletion**
   - Tests marking todos complete/incomplete
   - Verifies state updates
   - Checks completion date is set

3. **testDeleteTodo**
   - Tests todo deletion
   - Verifies state is updated correctly

4. **testFilterTodos**
   - Tests filtering by All/Active/Completed
   - Validates filtered results

5. **testAddTodoButtonTapped**
   - Tests navigation trigger

6. **testTodoTapped**
   - Tests detail view navigation

## Writing Tests with TCA

### Basic Test Structure

```swift
func testExample() async {
    let store = TestStore(
        initialState: FeatureState()
    ) {
        Feature()
    } withDependencies: {
        // Inject test dependencies
        $0.todoRepository = InMemoryTodoRepository()
    }

    // Send action
    await store.send(.someAction) {
        // Assert state changes
        $0.someProperty = expectedValue
    }

    // Receive async effects
    await store.receive(\.someOtherAction) {
        // Assert state changes from effect
        $0.anotherProperty = expectedValue
    }
}
```

### Key Concepts

#### 1. TestStore
TCA's testing helper that provides:
- State assertions
- Action tracking
- Effect verification
- Exhaustive testing

#### 2. Dependency Injection
Override dependencies for testing:

```swift
withDependencies: {
    $0.todoRepository = MockRepository()
    $0.uuid = { UUID(uuidString: "...")! }
    $0.date.now = Date(timeIntervalSince1970: 0)
}
```

#### 3. State Assertions
Verify state changes in closures:

```swift
await store.send(.action) {
    $0.property = newValue  // Assert exact value
}
```

#### 4. Effect Testing
Verify effects trigger actions:

```swift
await store.receive(\.actionFromEffect) {
    $0.result = effectResult
}
```

## Best Practices

### 1. Test Business Logic, Not UI
- Test reducers, not views
- Focus on state transformations
- Verify effects are triggered

### 2. Use Test Dependencies
- Never hit real APIs in tests
- Use in-memory repositories
- Control UUIDs and dates

### 3. Be Exhaustive
- TestStore enforces exhaustive testing
- Assert all state changes
- Receive all effects

### 4. Test Edge Cases
- Empty states
- Error conditions
- Concurrent operations

## Example: Testing a New Feature

Let's say you want to add a "mark all complete" feature:

### 1. Add the Action

```swift
// In TodoListFeature.swift
public enum Action {
    // ... existing actions
    case markAllComplete
}
```

### 2. Implement the Reducer

```swift
case .markAllComplete:
    for id in state.todos.ids {
        state.todos[id: id]?.isCompleted = true
        state.todos[id: id]?.completedAt = Date()
    }
    return .run { [todos = state.todos] send in
        for todo in todos {
            try await todoRepository.update(todo)
        }
    }
```

### 3. Write the Test

```swift
func testMarkAllComplete() async {
    let todos = [
        Todo.mock,
        Todo.mockCompleted,
        Todo(title: "Another task")
    ]

    let store = TestStore(
        initialState: TodoListFeature.State(
            todos: IdentifiedArray(uniqueElements: todos)
        )
    ) {
        TodoListFeature()
    } withDependencies: {
        $0.todoRepository = InMemoryTodoRepository(initialTodos: todos)
        $0.date.now = Date()
    }

    await store.send(.markAllComplete) {
        // All todos should be marked complete
        for id in $0.todos.ids {
            $0.todos[id: id]?.isCompleted = true
        }
    }

    // Verify final state
    XCTAssertTrue(store.state.todos.allSatisfy { $0.isCompleted })
}
```

## Common Test Patterns

### Testing Async Operations

```swift
func testAsyncLoad() async {
    let store = TestStore(initialState: State()) {
        Feature()
    }

    await store.send(.load) {
        $0.isLoading = true
    }

    await store.receive(\.dataLoaded) {
        $0.isLoading = false
        $0.data = expectedData
    }
}
```

### Testing Errors

```swift
func testError() async {
    let store = TestStore(initialState: State()) {
        Feature()
    } withDependencies: {
        $0.repository = FailingRepository()
    }

    await store.send(.load)

    await store.receive(\.errorOccurred) {
        $0.error = .networkError
    }
}
```

### Testing Debouncing

```swift
func testDebounce() async {
    let clock = TestClock()

    let store = TestStore(initialState: State()) {
        Feature()
    } withDependencies: {
        $0.continuousClock = clock
    }

    await store.send(.searchChanged("test"))

    // Advance clock
    await clock.advance(by: .seconds(0.3))

    await store.receive(\.performSearch)
}
```

## Debugging Tests

### Test Failures
TestStore will fail if:
- State doesn't match assertions
- Actions aren't received
- Unexpected actions occur

### Common Issues

**"Expected state to match..."**
- Your assertion doesn't match actual state
- Check the diff in the error message

**"Received unexpected action..."**
- Effect triggered an action you didn't expect
- Add `await store.receive(\.unexpectedAction)`

**"Expected to receive action..."**
- Effect didn't trigger expected action
- Check your reducer logic

### Debugging Tips

1. **Print state**:
   ```swift
   await store.send(.action)
   print(store.state)  // See actual state
   ```

2. **Skip exhaustivity** (temporarily):
   ```swift
   store.exhaustivity = .off
   ```

3. **Use breakpoints**:
   - Set breakpoints in reducer
   - Step through logic

## Test Coverage

Good test coverage includes:
- ✅ All actions tested
- ✅ All state transitions verified
- ✅ Error cases handled
- ✅ Edge cases covered
- ✅ Effects tested

Current coverage:
- TodoListFeature: 6 tests
- Need to add: TodoDetailFeature, TodoFormFeature tests

## Adding More Tests

To add tests for other features:

1. Create test file:
   ```
   Tests/TodoAppTests/TodoDetailFeatureTests.swift
   ```

2. Follow the same pattern:
   ```swift
   @MainActor
   final class TodoDetailFeatureTests: XCTestCase {
       func testEditTodo() async {
           // Test implementation
       }
   }
   ```

3. Regenerate project:
   ```bash
   xcodegen generate
   ```

## Resources

- [TCA Testing Docs](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Point-Free Testing Videos](https://www.pointfree.co/collections/composable-architecture/testing)

## Summary

- Use **XCTest** for all tests
- Use **TestStore** for TCA testing
- Inject **dependencies** for isolation
- Write **exhaustive** tests
- Test **business logic**, not UI
- Run tests with **Cmd+U**

Happy testing! 🧪
