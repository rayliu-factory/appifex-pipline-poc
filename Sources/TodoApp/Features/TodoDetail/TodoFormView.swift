import ComposableArchitecture
import SwiftUI

public struct TodoFormView: View {
    @Bindable var store: StoreOf<TodoFormFeature>

    public init(store: StoreOf<TodoFormFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $store.title)
                        .font(.headline)
                }

                Section("Description") {
                    TextEditor(text: $store.description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveButtonTapped)
                    }
                    .disabled(!store.isValid)
                }
            }
        }
    }
}

// Preview available in Xcode
// #Preview {
//     TodoFormView(
//         store: Store(
//             initialState: TodoFormFeature.State()
//         ) {
//             TodoFormFeature()
//         }
//     )
// }
