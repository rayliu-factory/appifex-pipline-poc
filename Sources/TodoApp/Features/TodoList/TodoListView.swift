import ComposableArchitecture
import SwiftUI

public struct TodoListView: View {
    @Bindable var store: StoreOf<TodoListFeature>

    public init(store: StoreOf<TodoListFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if store.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(store.filteredTodos) { todo in
                    TodoRowView(
                        todo: todo,
                        onToggle: { store.send(.toggleTodoCompletion(todo)) },
                        onTap: { store.send(.todoTapped(todo)) }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.send(.deleteTodo(todo))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Todos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.addTodoButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Picker("Filter", selection: $store.filter.sending(\.filterChanged)) {
                    ForEach(TodoListFeature.State.Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct TodoRowView: View {
    let todo: Todo
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(todo.isCompleted ? .green : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.headline)
                        .strikethrough(todo.isCompleted)
                        .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                    if !todo.description.isEmpty {
                        Text(todo.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Preview available in Xcode
// #Preview {
//     NavigationStack {
//         TodoListView(
//             store: Store(
//                 initialState: TodoListFeature.State(
//                     todos: [.mock, .mockCompleted]
//                 )
//             ) {
//                 TodoListFeature()
//             }
//         )
//     }
// }
