import ReactorKit
import RxSwift

final class MarkerPopupReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapDownload
    }
    
    enum Mutation {
        case setAdvertisement(Advertisement)
        case goToURL(urlString: String)
        case showErrorAlert(Error)
    }
    
    struct State {
        var advertisement: Advertisement
        @Pulse var goToURL: String?
    }
    
    let initialState: State
    private let advertisementService: AdvertisementServiceProtocol
    
    init(
        advertisementService: AdvertisementServiceProtocol,
        state: State = State(advertisement: Advertisement())
    ) {
        self.advertisementService = advertisementService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchAdvertisement()
            
        case .tapDownload:
            return .just(.goToURL(urlString: self.currentState.advertisement.linkUrl))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAdvertisement(let advertisement):
            newState.advertisement = advertisement
            
        case .goToURL(let urlString):
            newState.goToURL = urlString
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchAdvertisement() -> Observable<Mutation> {
        return self.advertisementService.fetchAdvertisements(position: .storeMarkerPopup)
            .compactMap { $0.first }
            .map { .setAdvertisement($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
