# App Flow & Navigation

Visual guide to understanding how the app works and how screens connect.

## 🎯 User Journey

```
┌─────────────────────────────────────────────────────────────┐
│                      App Launch                              │
│                    (TodoApp.swift)                           │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     AppFeature                               │
│              (Root Coordinator)                              │
│  • Manages navigation state                                  │
│  • Coordinates child features                                │
│  • Handles delegation                                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   TodoListView                               │
│            📝 Main Todo List Screen                          │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  [All] [Active] [Completed]  ← Filter Tabs         │    │
│  ├────────────────────────────────────────────────────┤    │
│  │  ○ Buy groceries                      [swipe →]    │    │
│  │    Milk, eggs, bread                               │    │
│  ├────────────────────────────────────────────────────┤    │
│  │  ✓ Finish project                     [swipe →]    │    │
│  │    Complete the demo app                           │    │
│  ├────────────────────────────────────────────────────┤    │
│  │  ○ Learn Swift Navigation             [swipe →]    │    │
│  └────────────────────────────────────────────────────┘    │
│                                           [+ Add] ──────┐   │
└─────────────────────────────────────────────────────────│───┘
                            │                             │
              Tap on Todo   │                             │ Tap + button
                            │                             │
         ┌──────────────────┴─────────────┐               │
         ▼                                 ▼               ▼
┌──────────────────────┐          ┌──────────────────────────┐
│  TodoDetailView      │          │    TodoFormView          │
│  📄 Detail Screen    │          │   ➕ New Todo Sheet      │
│                      │          │                          │
│  Title: [Edit]       │          │  Title: ____________     │
│                      │          │                          │
│  Description:        │          │  Description:            │
│  [Full text...]      │          │  __________________     │
│                      │          │  __________________     │
│  ☑ Completed         │          │                          │
│                      │          │  [Cancel]    [Save] ─┐   │
│  Created: 12/24/25   │          └──────────────────────│───┘
│                      │                                 │
│  [Cancel] [Edit] ──┐ │                                 │
└────────────────────│─┘                                 │
                     │                                   │
                     │                          Saves todo
                     │                                   │
                     └───────────┬───────────────────────┘
                                 │
                                 ▼
                      Updates TodoList state
                      View automatically refreshes
```

## 🔄 Data Flow

### Reading Data (Load Todos)

```
User opens app
      │
      ▼
TodoListView.onAppear
      │
      ▼
Send .onAppear action
      │
      ▼
TodoListFeature Reducer
      │
      ├─ Set isLoading = true
      │
      └─ Trigger Effect ──────────┐
                                   │
                                   ▼
                         TodoRepository.fetchAll()
                                   │
                                   ▼
                         Return [Todo] array
                                   │
                                   ▼
                         Send .todosLoaded([Todo])
                                   │
                                   ▼
                         TodoListFeature Reducer
                                   │
                                   ├─ Set isLoading = false
                                   ├─ Update todos array
                                   │
                                   ▼
                         TodoListView re-renders
                                   │
                                   ▼
                         User sees todo list
```

### Writing Data (Toggle Completion)

```
User taps checkbox
      │
      ▼
Send .toggleTodoCompletion(todo)
      │
      ▼
TodoListFeature Reducer
      │
      ├─ Create updated todo
      │
      └─ Trigger Effect ──────────┐
                                   │
                                   ▼
                         TodoRepository.update(todo)
                                   │
                                   ▼
                         Persist changes
                                   │
                                   ▼
                         Send .todoUpdated(todo)
                                   │
                                   ▼
                         TodoListFeature Reducer
                                   │
                                   ├─ Update local state
                                   │
                                   ▼
                         TodoListView re-renders
                                   │
                                   ▼
                         User sees updated todo
```

## 🧭 Navigation Flow

### Push Navigation (Todo Detail)

```
TodoListView
      │
      │ User taps todo
      ▼
Send .todoTapped(todo) ────► AppFeature Reducer
                                    │
                                    ├─ Set destination = .todoDetail(state)
                                    │
                                    ▼
                              AppView responds
                                    │
                                    ▼
                              .navigationDestination triggers
                                    │
                                    ▼
                              Push TodoDetailView
```

### Sheet Presentation (New Todo)

```
TodoListView
      │
      │ User taps + button
      ▼
Send .addTodoButtonTapped ──► AppFeature Reducer
                                    │
                                    ├─ Set destination = .todoForm(state)
                                    │
                                    ▼
                              AppView responds
                                    │
                                    ▼
                              .sheet triggers
                                    │
                                    ▼
                              Present TodoFormView
                                    │
                                    │ User fills form & saves
                                    ▼
                              Send .delegate(.todoCreated(todo))
                                    │
                                    ▼
                              AppFeature Reducer
                                    │
                                    ├─ Insert todo into list
                                    ├─ Dismiss sheet (automatic)
                                    │
                                    ▼
                              TodoListView updates
```

## 🎨 State Tree

```
AppFeature.State
│
├─ todoList: TodoListFeature.State
│   ├─ todos: IdentifiedArray<Todo>
│   ├─ isLoading: Bool
│   └─ filter: Filter (.all | .active | .completed)
│
└─ destination: Destination.State? (optional)
    │
    ├─ .todoDetail(TodoDetailFeature.State)
    │   ├─ todo: Todo
    │   └─ isEditing: Bool
    │
    └─ .todoForm(TodoFormFeature.State)
        ├─ title: String
        └─ description: String
```

## 🔌 Dependency Injection Flow

```
AppContainer (Factory)
      │
      ├─ todoRepository: TodoRepository
      │       │
      │       └─ Scoped as .singleton
      │
      ├─ uuidGenerator: () -> UUID
      │
      └─ dateGenerator: () -> Date

              │
              │ Injected via TCA DependencyValues
              ▼

TodoListFeature
      │
      ├─ @Dependency(\.todoRepository)
      │
      └─ Uses in effects

TodoDetailFeature
      │
      ├─ @Dependency(\.todoRepository)
      │
      └─ Uses in effects

TodoFormFeature
      │
      ├─ @Dependency(\.todoRepository)
      ├─ @Dependency(\.uuid)
      ├─ @Dependency(\.date.now)
      │
      └─ Uses in effects
```

## 🧪 Testing Flow

```
TestStore
      │
      ├─ Initial State
      │
      ├─ Send Action
      │       │
      │       ▼
      │  Reducer runs
      │       │
      │       ▼
      │  State updates
      │       │
      │       ▼
      │  Effects run
      │       │
      │       ▼
      │  Actions sent back
      │
      └─ Receive & Assert
              │
              └─ Verify state changes
```

### Example Test Flow

```
1. TestStore created with initial state
         todos: [mockTodo]

2. send(.toggleTodoCompletion(mockTodo))
         ↓
   Reducer updates local copy
         ↓
   Effect runs: repository.update()
         ↓
3. receive(.todoUpdated(updatedTodo))
         ↓
   Assert: todos[0].isCompleted == true
```

## 🎭 Feature Communication

### Parent → Child (Scoping)

```
AppFeature (Parent)
      │
      │ Scope state & actions
      ▼
TodoListFeature (Child)
      │
      └─ Receives scoped state
      └─ Sends scoped actions
```

### Child → Parent (Delegation)

```
TodoFormFeature
      │
      │ User saves todo
      ▼
Send .delegate(.todoCreated(todo))
      │
      ▼
AppFeature receives
      │
      ├─ Extracts delegate action
      ├─ Updates parent state
      └─ Dismisses child
```

## 📱 Screen Interactions

### TodoListView

| Action | Trigger | Result |
|--------|---------|--------|
| Tap todo | User taps row | Navigate to TodoDetailView |
| Tap checkbox | User taps circle | Toggle completion state |
| Swipe left | User swipes row | Show delete button |
| Tap delete | User taps trash | Remove todo from list |
| Tap + button | User taps toolbar | Present TodoFormView sheet |
| Change filter | User taps segment | Filter visible todos |

### TodoDetailView

| Action | Trigger | Result |
|--------|---------|--------|
| Tap Edit | User taps toolbar | Enter edit mode |
| Tap Done | User taps toolbar | Save changes & exit edit |
| Toggle completed | User taps switch | Update completion status |
| Modify text | User types | Update local state |

### TodoFormView

| Action | Trigger | Result |
|--------|---------|--------|
| Type title | User types | Update local state |
| Type description | User types | Update local state |
| Tap Save | User taps toolbar | Create todo & dismiss |
| Tap Cancel | User taps toolbar | Dismiss without saving |

## 🔍 Key Takeaways

1. **All state lives in reducers** - UI is a pure function of state
2. **Actions flow one direction** - View → Action → Reducer → State
3. **Effects are isolated** - Async work happens in `.run { }` blocks
4. **Navigation is state** - Changing `destination` drives navigation
5. **Features compose** - Parent features scope child features
6. **Dependencies inject** - External services via DI container

---

This flow demonstrates how TCA's architecture creates predictable, testable, and maintainable apps.
