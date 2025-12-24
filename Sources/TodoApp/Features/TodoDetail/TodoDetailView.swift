import ComposableArchitecture
import SwiftUI

public struct TodoDetailView: View {
    @Bindable var store: StoreOf<TodoDetailFeature>

    public init(store: StoreOf<TodoDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section {
                if store.isEditing {
                    TextField("Title", text: $store.todo.title)
                        .font(.headline)
                } else {
                    Text(store.todo.title)
                        .font(.headline)
                }
            }

            Section("Description") {
                if store.isEditing {
                    TextEditor(text: $store.todo.description)
                        .frame(minHeight: 100)
                } else {
                    if store.todo.description.isEmpty {
                        Text("No description")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(store.todo.description)
                    }
                }
            }

            Section("Status") {
                Toggle(isOn: Binding(
                    get: { store.todo.isCompleted },
                    set: { _ in store.send(.toggleCompletion) }
                )) {
                    Text("Completed")
                }

                LabeledContent("Created") {
                    Text(store.todo.createdAt, style: .date)
                        .foregroundStyle(.secondary)
                }

                if let completedAt = store.todo.completedAt {
                    LabeledContent("Completed") {
                        Text(completedAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Todo Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if store.isEditing {
                    Button("Done") {
                        store.send(.saveButtonTapped)
                    }
                } else {
                    Button("Edit") {
                        store.send(.editButtonTapped)
                    }
                }
            }

            if store.isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
            }
        }
    }
}

// Preview available in Xcode
// #Preview {
//     NavigationStack {
//         TodoDetailView(
//             store: Store(
//                 initialState: TodoDetailFeature.State(todo: .mock)
//             ) {
//                 TodoDetailFeature()
//             }
//         )
//     }
// }
