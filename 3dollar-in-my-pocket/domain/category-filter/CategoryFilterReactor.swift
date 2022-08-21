import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class CategoryFilterReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapBanner
        case tapCategory(index: Int)
    }
    
    enum Mutation {
        case setCategories(categories: [Categorizable])
        case setAdvertisement(Advertisement?)
        case goToWeb(url: String)
        case dismiss
        case showErrorAlert(Error)
    }
    
    struct State {
        var categories: [Categorizable]
        var advertisement: Advertisement?
    }
    
    let initialState: State
    let dismissPublisher = PublishRelay<Void>()
    private let storeType: StoreType
    private let advertisementService: AdvertisementServiceProtocol
    private let metaContext: MetaContext
    private let globalState: GlobalState
    
    init(
        storeType: StoreType,
        advertisementService: AdvertisementServiceProtocol,
        metaContext: MetaContext,
        globalState: GlobalState
    ) {
        self.storeType = storeType
        self.advertisementService = advertisementService
        self.metaContext = metaContext
        self.globalState = globalState
        if storeType == .streetFood {
            self.initialState = State(categories: metaContext.streetFoodCategories)
        } else {
            self.initialState = State(categories: metaContext.streetFoodCategories)
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchAdvertisement()
            
        case .tapBanner:
            guard let url = self.currentState.advertisement?.linkUrl else {
                return .just(.showErrorAlert(BaseError.custom("연결된 광고가 없습니다.")))
            }
            
            return .just(.goToWeb(url: url))
            
        case .tapCategory(let index):
            let tappedCategory = self.currentState.categories[index]
            
            self.globalState.updateCategoryFilter.onNext(tappedCategory)
            return .just(.dismiss)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCategories(let categories):
            newState.categories = categories
            
        case .setAdvertisement(let advertisement):
            newState.advertisement = advertisement
            
        case .goToWeb(let url):
            self.openURLPublisher.accept(url)
            
        case .dismiss:
            self.dismissPublisher.accept(())
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchAdvertisement() -> Observable<Mutation> {
        return self.advertisementService.fetchAdvertisements(position: .menuCategoryBanner)
            .map { $0.map(Advertisement.init(response:)).first }
            .map { .setAdvertisement($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
