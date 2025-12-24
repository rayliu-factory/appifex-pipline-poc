import ComposableArchitecture
import Factory
import Foundation

@Reducer
public struct TodoDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var todo: Todo
        public var isEditing: Bool

        public init(todo: Todo, isEditing: Bool = false) {
            self.todo = todo
            self.isEditing = isEditing
        }
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case editButtonTapped
        case saveButtonTapped
        case cancelButtonTapped
        case toggleCompletion
        case todoSaved(Todo)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Sendable {
            case todoUpdated(Todo)
            case dismiss
        }
    }

    @Dependency(\.todoRepository) var todoRepository
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .editButtonTapped:
                state.isEditing = true
                return .none

            case .saveButtonTapped:
                state.isEditing = false
                return .run { [todo = state.todo] send in
                    try await todoRepository.update(todo)
                    await send(.delegate(.todoUpdated(todo)))
                }

            case .cancelButtonTapped:
                state.isEditing = false
                return .none

            case .toggleCompletion:
                state.todo.isCompleted.toggle()
                state.todo.completedAt = state.todo.isCompleted ? Date() : nil

                return .run { [todo = state.todo] send in
                    try await todoRepository.update(todo)
                    await send(.delegate(.todoUpdated(todo)))
                }

            case .todoSaved:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
