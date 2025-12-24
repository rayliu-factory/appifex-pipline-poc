import ComposableArchitecture
import SwiftUI

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            TodoListView(
                store: store.scope(state: \.todoList, action: \.todoList)
            )
        }
        .sheet(
            item: $store.scope(state: \.destination?.todoForm, action: \.destination.todoForm)
        ) { store in
            TodoFormView(store: store)
        }
        .navigationDestination(
            item: $store.scope(state: \.destination?.todoDetail, action: \.destination.todoDetail)
        ) { store in
            TodoDetailView(store: store)
        }
    }
}

// Preview available in Xcode
// #Preview {
//     AppView(
//         store: Store(
//             initialState: AppFeature.State(
//                 todoList: TodoListFeature.State(
//                     todos: [.mock, .mockCompleted]
//                 )
//             )
//         ) {
//             AppFeature()
//         }
//     )
// }
