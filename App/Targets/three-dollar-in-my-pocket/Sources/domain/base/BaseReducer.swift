import Foundation
import Combine

protocol Reducer: AnyObject {
    associatedtype Action

    associatedtype Mutation

    associatedtype State

    associatedtype Route

    var actionPublisher: AnyPublisher<Action, Never> { get }
    var mutationPublisher: PassthroughSubject<Mutation, Never> { get }
    var statePublisher: PassthroughSubject<State, Never> { get }
    var routePublisher: PassthroughSubject<Route, Never> { get }
    var cancelable: Set<AnyCancellable> { get set }

    func mutate(action: Action) -> Mutation

    func reduce(mutation: Mutation) -> State
    
    func route(mutation: Mutation) -> Route
}

extension Reducer {
    func createStream() {
        actionPublisher
            .withUnretained(self)
            .map { owner, action in
                owner.mutate(action: action)
            }
            .subscribe(mutationPublisher)
            .store(in: &cancelable)

        mutationPublisher
            .withUnretained(self)
            .map { owner, mutation in
                owner.reduce(mutation: mutation)
            }
            .subscribe(statePublisher)
            .store(in: &cancelable)
        
        mutationPublisher
            .withUnretained(self)
            .map { owner, mutation in
                owner.route(mutation: mutation)
            }
            .subscribe(routePublisher)
            .store(in: &cancelable)
    }
}
