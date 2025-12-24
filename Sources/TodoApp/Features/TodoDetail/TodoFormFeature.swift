import ComposableArchitecture
import Foundation

@Reducer
public struct TodoFormFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String = ""
        public var description: String = ""

        public var isValid: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        public init(title: String = "", description: String = "") {
            self.title = title
            self.description = description
        }
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case saveButtonTapped
        case cancelButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Sendable {
            case todoCreated(Todo)
            case cancelled
        }
    }

    @Dependency(\.todoRepository) var todoRepository
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .saveButtonTapped:
                guard state.isValid else { return .none }

                let todo = Todo(
                    id: uuid(),
                    title: state.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: state.description.trimmingCharacters(in: .whitespacesAndNewlines),
                    isCompleted: false,
                    createdAt: now
                )

                return .run { send in
                    try await todoRepository.save(todo)
                    await send(.delegate(.todoCreated(todo)))
                    await dismiss()
                }

            case .cancelButtonTapped:
                return .run { send in
                    await send(.delegate(.cancelled))
                    await dismiss()
                }

            case .delegate:
                return .none
            }
        }
    }
}
