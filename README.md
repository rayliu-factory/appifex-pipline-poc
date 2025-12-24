# Todo App - TCA + Factory DI + Swift Navigation Demo

A production-ready iOS todo list application demonstrating modern Swift architecture patterns.

## ⚡ Quick Start

```bash
open TodoApp.xcodeproj
```

Then press **`Cmd+R`** to build and run! See [GETTING_STARTED.md](GETTING_STARTED.md) for details.

## 🎯 Architecture Patterns

- **The Composable Architecture (TCA)** - Unidirectional data flow and state management
- **Factory Dependency Injection** - Type-safe dependency management
- **Swift Navigation** - Declarative navigation and routing
- **XcodeGen** - Reproducible project generation

## 🏗️ Architecture Overview

This app showcases a clean, modular architecture with clear separation of concerns:

### Project Structure

```
TodoApp/
├── Models/
│   └── Todo.swift                    # Domain models
├── Services/
│   └── TodoRepository.swift          # Data layer abstraction
├── DependencyInjection/
│   └── AppContainer.swift            # Factory DI container
├── Features/
│   ├── TodoList/
│   │   ├── TodoListFeature.swift    # TCA reducer for list
│   │   └── TodoListView.swift       # List view
│   └── TodoDetail/
│       ├── TodoDetailFeature.swift  # TCA reducer for detail
│       ├── TodoDetailView.swift     # Detail view
│       ├── TodoFormFeature.swift    # TCA reducer for creation
│       └── TodoFormView.swift       # Creation form view
└── App/
    ├── AppFeature.swift              # Root reducer with navigation
    ├── AppView.swift                 # Root view
    └── TodoApp.swift                 # App entry point
```

## 🚀 Key Features

### The Composable Architecture (TCA)
- **Unidirectional Data Flow**: All state changes flow through reducers
- **Testable by Default**: Pure functions make testing straightforward
- **Effect Management**: Async operations handled via structured concurrency
- **Modular Features**: Each feature is self-contained and composable

### Factory Dependency Injection
- **Type-Safe**: Compile-time checking of dependencies
- **Scoped Dependencies**: Singleton, cached, and factory scopes
- **Easy Testing**: Simple mocking and stubbing for tests
- **Container Pattern**: Centralized dependency configuration

### Swift Navigation
- **Declarative Navigation**: Navigation state is part of your reducer state
- **Deep Linking Ready**: Navigate programmatically with ease
- **SwiftUI Integration**: Works seamlessly with NavigationStack and sheets
- **Type-Safe Routes**: Enum-based destination modeling

## 📦 Dependencies

All dependencies are managed via Swift Package Manager:

- [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) - State management
- [swift-navigation](https://github.com/pointfreeco/swift-navigation) - Navigation tools
- [Factory](https://github.com/hmlongco/Factory) - Dependency injection

## 🛠️ Building & Running

### Requirements
- **Xcode 15.0+** (full Xcode, not just Command Line Tools)
- iOS 17.0+
- Swift 5.9+

### Quick Start (Recommended)

1. Clone the repository:
```bash
git clone <repository-url>
cd appifex-pipeline-poc
```

2. **Open the Xcode project** (generated with XcodeGen):
```bash
open TodoApp.xcodeproj
```

3. Wait for Xcode to resolve package dependencies (this may take a minute)

4. Build and run:
   - Select the **TodoApp** scheme
   - Select an iOS 17+ simulator or device
   - Press `Cmd+R` to build and run
   - Or use `Cmd+B` to just build

### Regenerating the Xcode Project

If you need to regenerate the project (after modifying `project.yml`):

```bash
# Install XcodeGen (one time)
brew install xcodegen

# Regenerate project
xcodegen generate

# Open project
open TodoApp.xcodeproj
```

### Alternative: Using Swift Package

You can also open the Swift Package directly:
```bash
open Package.swift
```

Note: This approach has limitations for iOS apps. The `.xcodeproj` approach is recommended

### Running Tests

You can run tests in Xcode or via command line:

```bash
# Run tests in Xcode: Cmd+U

# Or use Swift Package Manager (requires full Xcode installation)
swift test --destination "platform=iOS Simulator,name=iPhone 15"
```

### Important Notes

- This is an **iOS-only** app and requires an iOS simulator or device
- The Swift Package Manager CLI (`swift build`) requires the full Xcode installation, not just Command Line Tools
- Previews are available when opening individual view files in Xcode
- All dependencies are fetched automatically via Swift Package Manager

## 🎯 Code Examples

### TCA Reducer Pattern

```swift
@Reducer
struct TodoListFeature {
    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<Todo> = []
    }

    enum Action {
        case todoTapped(Todo)
        case toggleCompletion(Todo)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .todoTapped(let todo):
                // Handle navigation
                return .none
            case .toggleCompletion(let todo):
                // Update todo state
                return .run { /* save to repository */ }
            }
        }
    }
}
```

### Factory DI Container

```swift
extension AppContainer {
    var todoRepository: Factory<TodoRepository> {
        self { InMemoryTodoRepository() }
            .scope(.singleton)
    }
}

// Usage in TCA
@Dependency(\.todoRepository) var todoRepository
```

### Navigation with Destinations

```swift
@Reducer
enum Destination {
    case todoDetail(TodoDetailFeature)
    case todoForm(TodoFormFeature)
}

// In your view
.navigationDestination(item: $store.scope(
    state: \.destination?.todoDetail,
    action: \.destination.todoDetail
)) { store in
    TodoDetailView(store: store)
}
```

## 🧪 Testing

The architecture is designed for testability:

```swift
@Test
func testToggleTodoCompletion() async {
    let store = TestStore(
        initialState: TodoListFeature.State(
            todos: [Todo.mock]
        )
    ) {
        TodoListFeature()
    }

    await store.send(.toggleCompletion(Todo.mock)) {
        $0.todos[0].isCompleted = true
    }
}
```

## 📚 Learning Resources

### The Composable Architecture
- [Official Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Point-Free Videos](https://www.pointfree.co/collections/composable-architecture)

### Factory DI
- [Factory Documentation](https://github.com/hmlongco/Factory/blob/main/README.md)

### Swift Navigation
- [Swift Navigation Docs](https://github.com/pointfreeco/swift-navigation)

## 🎨 App Features

- ✅ Create new todos with title and description
- ✅ Mark todos as complete/incomplete
- ✅ Filter todos (All, Active, Completed)
- ✅ Edit existing todos
- ✅ Delete todos with swipe action
- ✅ View todo details with creation/completion dates
- ✅ Persistent in-memory storage

## 🔮 Future Enhancements

- [ ] Persistent storage (Core Data / SwiftData)
- [ ] Categories and tags
- [ ] Due dates and reminders
- [ ] Search functionality
- [ ] Dark mode support
- [ ] Accessibility improvements
- [ ] Unit and integration tests
- [ ] CI/CD pipeline

## 📄 License

This is a demonstration project for educational purposes.

---

Built with ❤️ using Swift and The Composable Architecture
