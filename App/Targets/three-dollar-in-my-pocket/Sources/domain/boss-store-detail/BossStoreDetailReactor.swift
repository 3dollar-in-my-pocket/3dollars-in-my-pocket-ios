import CoreLocation

import ReactorKit
import RxSwift
import RxCocoa

final class BossStoreDetailReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapCurrentLocation
        case tapBookmark
        case tapSNSButton
        case tapShare
        case showTotalMenus
        case tapFeedback
    }
    
    enum Mutation {
        case setStore(BossStore)
        case pushShare(BossStore)
        case setBookmark(Bool)
        case pushFeedback(storeId: String)
        case moveCamera(location: CLLocation)
        case pushURL(url: String?)
        case updateFeedbacks([BossStoreFeedback])
        case showTotalMenus
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
        case showToast(message: String)
    }
    
    struct State {
        var store: BossStore
        var showTotalMenus: Bool
    }
    
    let storeId: String
    let initialState: State
    let pushFeedbackPublisher = PublishRelay<String>()
    let pushSharePublisher = PublishRelay<BossStore>()
    let moveCameraPublisher = PublishRelay<CLLocation>()
    let pushURLPublisher = PublishRelay<String?>()
    private let storeService: StoreServiceProtocol
    private let locationService: LocationManagerProtocol
    private let bookamrkService: BookmarkServiceProtocol
    private let globalState: GlobalState
    private var userDefaults: UserDefaultsUtil
    private var analyticsManager: AnalyticsManagerProtocol
    
    init(
        storeId: String,
        storeService: StoreServiceProtocol,
        bookmarkService: BookmarkServiceProtocol,
        locationManaber: LocationManagerProtocol,
        globalState: GlobalState,
        userDefaults: UserDefaultsUtil,
        analyticsManager: AnalyticsManagerProtocol,
        state: State = State(store: BossStore(), showTotalMenus: false)
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.bookamrkService = bookmarkService
        self.locationService = locationManaber
        self.globalState = globalState
        self.userDefaults = userDefaults
        self.analyticsManager = analyticsManager
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            self.clearKakaoLinkIfExisted()
            self.analyticsManager.logEvent(
                event: .viewBossStoreDetail(storeId: self.storeId),
                screen: .bossStoreDetail
            )
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.fetchBossStore(storeId: self.storeId),
                .just(.showLoading(isShow: false))
            ])
            
        case .tapCurrentLocation:
            return self.fetchCurrentLocation()
            
        case .tapBookmark:
            let isBookmarked = self.currentState.store.isBookmarked
            let store = self.currentState.store
            
            if isBookmarked {
                return self.unBookmarkStore(storeId: store.id)
            } else {
                return self.bookmarkStore(store: store)
            }
            
        case .tapSNSButton:
            return .just(.pushURL(url: self.currentState.store.snsUrl))
            
        case .tapShare:
            return .just(.pushShare(self.currentState.store))
            
        case .showTotalMenus:
            return .just(.showTotalMenus)
            
        case .tapFeedback:
            return .just(.pushFeedback(storeId: self.storeId))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.updateFeedbacks
                .map { .updateFeedbacks($0) }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStore(let store):
            newState.store = store
            
        case .pushShare(let store):
            self.pushSharePublisher.accept(store)
            
        case .setBookmark(let isBookmarked):
            newState.store.isBookmarked = isBookmarked
            
        case .pushFeedback(let storeId):
            self.pushFeedbackPublisher.accept(storeId)
            
        case .moveCamera(let location):
            self.moveCameraPublisher.accept(location)
            
        case .pushURL(let url):
            self.pushURLPublisher.accept(url)
            
        case .updateFeedbacks(let feedbacks):
            newState.store.feedbacks = feedbacks
            newState.store.feedbackCount = feedbacks.map { $0.count }.reduce(0, +)
            
        case .showTotalMenus:
            newState.showTotalMenus = true
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
            
        case .showToast(let message):
            self.showToastPublisher.accept(message)
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
    
    private func fetchCurrentLocation() -> Observable<Mutation> {
        return self.locationService.getCurrentLocation()
            .map { .moveCamera(location: $0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func clearKakaoLinkIfExisted() {
        if !self.userDefaults.shareLink.isEmpty {
            self.userDefaults.shareLink = ""
        }
    }
    
    private func bookmarkStore(store: BossStore) -> Observable<Mutation> {
        return self.bookamrkService.bookmarkStore(storeType: .foodTruck, storeId: store.id)
            .do(onNext: { [weak self] _ in
                self?.globalState.addBookmarkStore.onNext(store)
            })
            .flatMap { _ -> Observable<Mutation> in
                return .merge([
                    .just(.setBookmark(true)),
                    .just(.showToast(message: "store_detail_bookmark_toast".localized))
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func unBookmarkStore(storeId: String) -> Observable<Mutation> {
        return self.bookamrkService.unBookmarkStore(storeType: .foodTruck, storeId: storeId)
            .do(onNext: { [weak self] _ in
                self?.globalState.deleteBookmarkStore.onNext([storeId])
            })
                .flatMap { _ -> Observable<Mutation> in
                    return .merge([
                        .just(.setBookmark(false)),
                        .just(.showToast(message: "store_detail_unbookmark_toast".localized))
                    ])
                }
            .catch { .just(.showErrorAlert($0)) }
    }
}
