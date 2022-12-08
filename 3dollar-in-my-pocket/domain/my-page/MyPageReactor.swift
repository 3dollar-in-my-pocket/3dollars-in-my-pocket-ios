import ReactorKit
import RxSwift

final class MyPageReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case refresh
        case tapMyMedal
        case tapVisitHistory(row: Int)
        case tapBookmark(row: Int)
    }
    
    enum Mutation {
        case setUser(User)
        case setVisitHistories([VisitHistory])
        case setBookmarks([StoreProtocol])
        case endRefresh
        case pushMyMedal(Medal)
        case pushStoreDetail(storeId: Int)
        case showErrorAlert(Error)
    }
    
    struct State {
        var user: User
        var visitHistories: [VisitHistory]
        var bookmarks: [StoreProtocol]
        @Pulse var endRefreshing: Void?
        @Pulse var pushStoreDetail: Int?
        @Pulse var pushMyMedal: Medal?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let visitHistoryService: VisitHistoryServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let size = 5
    
    init(
        userService: UserServiceProtocol,
        visitHistoryService: VisitHistoryServiceProtocol,
        bookmarkService: BookmarkServiceProtocol,
        state: State = State(user: User(), visitHistories: [], bookmarks: [])
    ) {
        self.userService = userService
        self.visitHistoryService = visitHistoryService
        self.bookmarkService = bookmarkService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .merge([
                self.fetchMyActivityInfo(),
                self.fetchVisitHistories(),
                self.fetchBookmarks()
            ])
            
        case .refresh:
            let refreshData = Observable.merge([
                self.fetchMyActivityInfo(),
                self.fetchVisitHistories(),
                self.fetchBookmarks()
            ])
            
            return .concat([
                refreshData,
                .just(.endRefresh)
            ])
            
        case .tapMyMedal:
            let currentMedal = self.currentState.user.medal
            
            return .just(.pushMyMedal(currentMedal))
            
        case .tapVisitHistory(let row):
            guard !self.currentState.visitHistories.isEmpty else { return .empty() }
            let tappedVisitHistory = self.currentState.visitHistories[row]
            
            return .just(.pushStoreDetail(storeId: tappedVisitHistory.storeId))
            
        case .tapBookmark(let row):
            guard !self.currentState.bookmarks.isEmpty else { return .empty() }
            let tappedBookmark = self.currentState.bookmarks[row]
            
            return .just(.pushStoreDetail(storeId: Int(tappedBookmark.id) ?? 0))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setUser(let user):
            newState.user = user
            
        case .setVisitHistories(let visitHistories):
            newState.visitHistories = visitHistories
            
        case .setBookmarks(let stores):
            newState.bookmarks = stores
            
        case .endRefresh:
            newState.endRefreshing = ()
            
        case .pushMyMedal(let medal):
            newState.pushMyMedal = medal
            
        case .pushStoreDetail(let storeId):
            newState.pushStoreDetail = storeId
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchMyActivityInfo() -> Observable<Mutation> {
        return self.userService.fetchUserActivity()
            .map { .setUser($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchVisitHistories() -> Observable<Mutation> {
        return self.visitHistoryService.fetchVisitHistory(cursor: nil, size: self.size)
            .map { $0.contents.map { VisitHistory(response: $0) } }
            .map { .setVisitHistories($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchBookmarks() -> Observable<Mutation> {
        return self.bookmarkService.fetchMyBookmarks(cursor: nil, size: self.size)
            .map { .setBookmarks($0.bookmarkFolder.bookmarks) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
