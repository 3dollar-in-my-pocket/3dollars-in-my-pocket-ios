import ReactorKit
import RxSwift
import RxCocoa

final class BossStoreDetailReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapShare
        case tapFeedback
    }
    
    enum Mutation {
        case setStore(BossStore)
        case pushShare
        case pushFeedback(storeId: String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var store: BossStore
    }
    
    let storeId: String
    let initialState: State
    let pushFeedbackPublisher = PublishRelay<String>()
    let pushSharePublisher = PublishRelay<Void>()
    private let storeService: StoreServiceProtocol
    private let locationService: LocationManagerProtocol
    
    
    init(
        storeId: String,
        storeService: StoreServiceProtocol,
        locationManaber: LocationManagerProtocol,
        state: State = State(store: BossStore())
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.locationService = locationManaber
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.fetchBossStore(storeId: self.storeId),
                .just(.showLoading(isShow: false))
            ])
            
        case .tapShare:
            return .empty()
            
        case .tapFeedback:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStore(let store):
            newState.store = store
            
        case .pushShare:
            break
            
        case .pushFeedback(let storeId):
            self.pushFeedbackPublisher.accept(storeId)
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchBossStore(storeId: String) -> Observable<Mutation> {
        return self.locationService.getCurrentLocation()
            .flatMap { [weak self] location -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.storeService.fetchBossStore(
                    bossStoreId: self.storeId,
                    currentLocation: location
                )
                .map { .setStore($0) }
            }
            .catch { .just(.showErrorAlert($0)) }
    }
}
