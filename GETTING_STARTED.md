# Getting Started with TodoApp

Welcome! This is your **TodoApp Xcode project** - a production-ready iOS app demonstrating The Composable Architecture, Factory DI, and Swift Navigation.

## ⚡ Quick Start (30 seconds)

```bash
# Open the Xcode project
open TodoApp.xcodeproj
```

Then in Xcode:
1. Select **TodoApp** scheme
2. Choose an iOS 17+ simulator
3. Press **`Cmd+R`**

**That's it!** The app will build and run.

## 📱 What You'll See

The app launches with a working todo list featuring:
- ✅ Sample todos pre-loaded
- ✅ Filter tabs (All / Active / Completed)
- ✅ Tap a todo to view details
- ✅ Tap ➕ to create new todos
- ✅ Swipe to delete todos
- ✅ Toggle completion status

## 🎯 Try These Features

1. **Create a Todo**
   - Tap the ➕ button
   - Enter a title and description
   - Tap Save

2. **Mark Complete**
   - Tap the circle icon next to any todo
   - Watch it move to the Completed filter

3. **View Details**
   - Tap any todo row
   - See full description and metadata
   - Tap Edit to modify

4. **Filter Todos**
   - Use the segmented control at the bottom
   - Switch between All, Active, and Completed

5. **Delete a Todo**
   - Swipe left on any todo
   - Tap the trash icon

## 🏗️ Project Structure

This is a **real iOS app** built with modern Swift patterns:

### Architecture
- **TCA (The Composable Architecture)** - State management
- **Factory** - Dependency injection
- **Swift Navigation** - Type-safe routing

### Features
- **TodoList** - Main list with filtering
- **TodoDetail** - View and edit todos
- **TodoForm** - Create new todos

### Code Organization
```
Sources/TodoApp/
├── Models/          # Domain models
├── Services/        # Data layer
├── DI/              # Dependency injection
├── Features/        # TCA features
└── App/             # Root coordinator
```

## 📚 Documentation

Choose your path:

### Just Want to Code?
→ Read [QUICKSTART.md](QUICKSTART.md)

### Want to Understand the Architecture?
→ Read [ARCHITECTURE.md](ARCHITECTURE.md)

### Need Visual Diagrams?
→ Read [APP_FLOW.md](APP_FLOW.md)

### Working with the Xcode Project?
→ Read [XCODE_PROJECT_GUIDE.md](XCODE_PROJECT_GUIDE.md)

### Want the Full Overview?
→ Read [README.md](README.md)

## 🧪 Running Tests

Press **`Cmd+U`** in Xcode to run all tests.

Tests demonstrate:
- Loading todos
- Toggling completion
- Deleting todos
- Filtering by status

## 🔧 Project Configuration

This project uses **XcodeGen** for project generation:

- **Source of Truth**: `project.yml`
- **Generated**: `TodoApp.xcodeproj`
- **Dependencies**: Managed by Swift Package Manager

### Regenerating the Project

If you modify `project.yml`:

```bash
xcodegen generate
```

## 🎓 Learning Path

### Beginner
1. ✅ Run the app
2. ✅ Try all features
3. ✅ Read the code
4. ✅ Run the tests

### Intermediate
1. ✅ Understand TCA reducers
2. ✅ Learn the navigation flow
3. ✅ Explore dependency injection
4. ✅ Add a new feature

### Advanced
1. ✅ Add persistent storage
2. ✅ Implement search
3. ✅ Add categories
4. ✅ Create custom animations

## 🐛 Troubleshooting

### App Won't Build?

```bash
# Clean build folder
# In Xcode: Product > Clean Build Folder (Cmd+Shift+K)

# Reset package caches
# In Xcode: File > Packages > Reset Package Caches

# Regenerate project
xcodegen generate
```

### Dependencies Not Resolving?

In Xcode:
1. **File > Packages > Reset Package Caches**
2. **File > Packages > Resolve Package Versions**
3. Wait for completion

### Simulator Not Working?

1. Open **Xcode > Settings > Platforms**
2. Ensure iOS 17+ runtime is installed
3. Download if needed
4. Restart Xcode

## 💡 Next Steps

Now that you have the app running:

### Explore the Code
- Open [TodoListFeature.swift](Sources/TodoApp/Features/TodoList/TodoListFeature.swift)
- See how state management works
- Understand the reducer pattern

### Modify the App
- Change the UI in [TodoListView.swift](Sources/TodoApp/Features/TodoList/TodoListView.swift)
- Add a new field to [Todo.swift](Sources/TodoApp/Models/Todo.swift)
- Create a new feature

### Write Tests
- Open [TodoListFeatureTests.swift](Tests/TodoAppTests/TodoListFeatureTests.swift)
- Add new test cases
- Learn TCA's `TestStore`

### Learn the Patterns
- Read about TCA: https://pointfreeco.github.io/swift-composable-architecture/
- Explore Factory DI: https://github.com/hmlongco/Factory
- Study Swift Navigation: https://github.com/pointfreeco/swift-navigation

## 📋 Checklist

- [x] ✅ XcodeGen installed
- [x] ✅ TodoApp.xcodeproj generated
- [x] ✅ All source files included
- [x] ✅ Dependencies configured
- [x] ✅ Tests ready
- [x] ✅ Documentation complete

## 🎉 You're All Set!

Your TodoApp is ready to use. Start exploring, learning, and building!

**Open the project:**
```bash
open TodoApp.xcodeproj
```

**Questions?** Check the documentation in this repository.

**Happy coding!** 🚀
