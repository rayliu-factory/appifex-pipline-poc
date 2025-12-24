# Quick Start Guide

Get up and running with this Todo app demo in 5 minutes!

## Prerequisites

Before you begin, ensure you have:
- ✅ **Xcode 15.0 or later** installed (download from Mac App Store)
- ✅ macOS with sufficient storage for iOS Simulator
- ✅ Basic familiarity with Swift and SwiftUI

## Step 1: Get the Code

```bash
git clone <repository-url>
cd appifex-pipeline-poc
```

## Step 2: Open in Xcode

```bash
open Package.swift
```

Xcode will automatically:
- Resolve package dependencies
- Download TCA, Swift Navigation, and Factory
- Set up the build environment

**⏱️ This may take 1-2 minutes the first time**

## Step 3: Select a Simulator

1. In Xcode's toolbar, click the scheme selector (next to the play/stop buttons)
2. Choose any iOS 17+ simulator (e.g., "iPhone 15")
3. If you don't have a simulator, Xcode will prompt you to download one

## Step 4: Build and Run

Press **`Cmd+R`** or click the ▶️ Play button

The app will:
- ✅ Build (first build may take a minute)
- ✅ Launch the iOS Simulator
- ✅ Display a todo list with sample data

## What You'll See

### Main Screen (TodoListView)
- A list of sample todos
- Filter tabs: All / Active / Completed
- ➕ button to add new todos
- Swipe left on any todo to delete

### Interactions to Try
1. **Toggle completion**: Tap the circle icon to mark todos complete
2. **View details**: Tap a todo to see its detail screen
3. **Add new todo**: Tap the ➕ button, enter a title and description
4. **Edit todo**: In detail view, tap "Edit" to modify
5. **Delete todo**: Swipe left and tap the trash icon
6. **Filter todos**: Use the segmented control at the bottom

## Understanding the Code

### Key Files to Explore

#### 1. **Models** ([Todo.swift](Sources/TodoApp/Models/Todo.swift))
The domain model representing a todo item.

#### 2. **TodoList Feature** ([TodoListFeature.swift](Sources/TodoApp/Features/TodoList/TodoListFeature.swift))
- State management for the list
- Actions like adding, deleting, toggling completion
- Effect handling for loading data

#### 3. **TodoList View** ([TodoListView.swift](Sources/TodoApp/Features/TodoList/TodoListView.swift))
- SwiftUI view rendering the list
- Bindings to the store
- UI components for todo rows

#### 4. **App Root** ([AppFeature.swift](Sources/TodoApp/App/AppFeature.swift))
- Parent reducer coordinating navigation
- Destination enum for routing
- Delegation handling between features

#### 5. **Dependency Injection** ([AppContainer.swift](Sources/TodoApp/DependencyInjection/AppContainer.swift))
- Factory configuration
- Mock data setup
- Dependency scoping

## Common Tasks

### Adding a New Feature

1. Create feature directory: `Sources/TodoApp/Features/YourFeature/`
2. Add `YourFeature.swift` with `@Reducer` struct
3. Add `YourView.swift` with SwiftUI view
4. Wire it up in `AppFeature` for navigation

### Modifying Todo Model

Edit [Todo.swift](Sources/TodoApp/Models/Todo.swift):
```swift
public struct Todo: Identifiable, Equatable, Codable {
    // Add new properties here
    public var priority: Priority?
    public var dueDate: Date?
}
```

### Changing Storage

Replace `InMemoryTodoRepository` in [AppContainer.swift](Sources/TodoApp/DependencyInjection/AppContainer.swift):
```swift
var todoRepository: Factory<TodoRepository> {
    self { CoreDataTodoRepository() }  // Your implementation
        .scope(.singleton)
}
```

### Running Tests

Press **`Cmd+U`** to run all tests

View test example in [TodoListFeatureTests.swift](Tests/TodoAppTests/TodoListFeatureTests.swift)

## Troubleshooting

### Build Fails
- ✅ Ensure you have **full Xcode** (not just Command Line Tools)
- ✅ Check that Xcode version is 15.0+
- ✅ Try cleaning: `Product > Clean Build Folder` (`Cmd+Shift+K`)
- ✅ Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Dependencies Not Resolving
- ✅ Check internet connection
- ✅ File > Packages > Reset Package Caches
- ✅ File > Packages > Update to Latest Package Versions

### Simulator Not Starting
- ✅ Open Xcode > Settings > Platforms
- ✅ Download iOS 17+ runtime if missing
- ✅ Restart Xcode and your Mac if needed

## Next Steps

### Learn More
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture docs
2. Read [README.md](README.md) for comprehensive overview
3. Watch [Point-Free TCA videos](https://www.pointfree.co/collections/composable-architecture)

### Extend the App
- [ ] Add persistent storage (Core Data / SwiftData)
- [ ] Implement due dates and reminders
- [ ] Add categories/tags for todos
- [ ] Create custom themes
- [ ] Add search functionality
- [ ] Implement undo/redo
- [ ] Add drag-to-reorder

### Best Practices to Follow
- ✅ Keep reducers pure (no side effects)
- ✅ Use dependency injection for all external dependencies
- ✅ Model navigation as state
- ✅ Write tests for business logic
- ✅ Use `IdentifiedArray` for collections

## Getting Help

- 📖 [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- 💬 [TCA Discussions](https://github.com/pointfreeco/swift-composable-architecture/discussions)
- 🐛 [Report Issues](https://github.com/pointfreeco/swift-composable-architecture/issues)

## Summary

You now have a fully functional todo app built with:
- ✅ The Composable Architecture for state management
- ✅ Factory for dependency injection
- ✅ Swift Navigation for routing
- ✅ Modern Swift concurrency (async/await)
- ✅ Comprehensive testing infrastructure

**Happy coding!** 🚀
