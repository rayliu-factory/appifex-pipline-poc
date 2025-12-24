import ComposableArchitecture
import Foundation
import SwiftNavigation

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State {
        public var todoList: TodoListFeature.State
        @Presents public var destination: Destination.State?

        public init(
            todoList: TodoListFeature.State = TodoListFeature.State(),
            destination: Destination.State? = nil
        ) {
            self.todoList = todoList
            self.destination = destination
        }
    }

    public enum Action: Sendable {
        case todoList(TodoListFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.todoList, action: \.todoList) {
            TodoListFeature()
        }

        Reduce { state, action in
            switch action {
            case .todoList(.addTodoButtonTapped):
                state.destination = .todoForm(TodoFormFeature.State())
                return .none

            case let .todoList(.todoTapped(todo)):
                state.destination = .todoDetail(TodoDetailFeature.State(todo: todo))
                return .none

            case let .destination(.presented(.todoForm(.delegate(.todoCreated(todo))))):
                state.todoList.todos.insert(todo, at: 0)
                return .none

            case .destination(.presented(.todoForm(.delegate(.cancelled)))):
                return .none

            case let .destination(.presented(.todoDetail(.delegate(.todoUpdated(todo))))):
                state.todoList.todos[id: todo.id] = todo
                return .none

            case .destination(.presented(.todoDetail(.delegate(.dismiss)))):
                state.destination = nil
                return .none

            case .todoList:
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    @Reducer
    public enum Destination {
        case todoDetail(TodoDetailFeature)
        case todoForm(TodoFormFeature)
    }
}
