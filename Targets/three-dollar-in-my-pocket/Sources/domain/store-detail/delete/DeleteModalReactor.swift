import RxSwift
import RxCocoa
import ReactorKit

final class DeleteModalReactor: BaseReactor, Reactor {
    enum Action {
        case tapReason(DeleteReason)
        case tapDelete
    }
    
    enum Mutation {
        case setDeleteReason(DeleteReason)
        case dismiss
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var deleteReason: DeleteReason?
    }
    
    let initialState: State
    let dismissPublisher = PublishRelay<Void>()
    private let storeId: Int
    private let storeService: StoreServiceProtocol
    
    init(
        storeId: Int,
        storeService: StoreServiceProtocol,
        state: State = State(deleteReason: nil)
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapReason(let reason):
            return .just(.setDeleteReason(reason))
            
        case .tapDelete:
            guard let selectedReason = self.currentState.deleteReason else {
                return .error(BaseError.unknown)
            }
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.requestDelete(storeId: self.storeId, deleteReason: selectedReason),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setDeleteReason(let reason):
            newState.deleteReason = reason
            
        case .dismiss:
            self.dismissPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func requestDelete(storeId: Int, deleteReason: DeleteReason) -> Observable<Mutation> {
        return self.storeService.deleteStore(storeId: storeId, deleteReasonType: deleteReason)
            .map { .dismiss }
            .catch { .just(.showErrorAlert(error: $0)) }
    }
}
