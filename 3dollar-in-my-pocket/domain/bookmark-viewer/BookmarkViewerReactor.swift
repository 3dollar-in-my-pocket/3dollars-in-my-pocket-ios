import ReactorKit
import RxSwift

final class BookmarkViewerReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case willDisplay(row: Int)
        case tapStore(row: Int)
    }
    
    enum Mutation {
        case setBookmarkTitle(String)
        case setBookmarkDescription(String)
        case setUser(User)
        case setTotalCount(Int)
        case appendStores([StoreProtocol])
        case pushStoreDetail(StoreProtocol)
        case showErrorAlert(Error)
    }
    
    struct State {
        var bookmarkTitle: String
        var bookmarkDescription: String
        var user: User
        var totalCount: Int
        var stores: [StoreProtocol]
        @Pulse var pushStoreDetail: StoreProtocol?
    }
    
    let initialState: State
    private let bookmarkService: BookmarkServiceProtocol
    private let folderId: String
    private var hasMore: Bool = true
    private var nextCursor: String?
    
    init(
        folderId: String,
        bookmarkService: BookmarkServiceProtocol,
        state: State = State(
            bookmarkTitle: "",
            bookmarkDescription: "",
            user: User(),
            totalCount: 0,
            stores: []
        )
    ) {
        self.folderId = folderId
        self.bookmarkService = bookmarkService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            guard self.hasMore else { return .empty() }
            return self.fetchBookmarkFolder(folderId: folderId, cursor: self.nextCursor)
            
        case .willDisplay(let row):
            guard self.canLoadMore(willDisplayRow: row) else { return .empty() }
            return self.fetchBookmarkFolder(folderId: folderId, cursor: self.nextCursor)
            
        case .tapStore(let row):
            let tappedStore = self.currentState.stores[row]
            
            return .just(.pushStoreDetail(tappedStore))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBookmarkTitle(let title):
            newState.bookmarkTitle = title
            
        case .setBookmarkDescription(let description):
            newState.bookmarkDescription = description
            
        case .setUser(let user):
            newState.user = user
            
        case .setTotalCount(let totalCount):
            newState.totalCount = totalCount
            
        case .appendStores(let stores):
            newState.stores.append(contentsOf: stores)
            
        case .pushStoreDetail(let store):
            newState.pushStoreDetail = store
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchBookmarkFolder(folderId: String, cursor: String?) -> Observable<Mutation> {
        return self.bookmarkService.fetchBookmarkFolder(folderId: folderId, cursor: cursor)
            .do(onNext: { [weak self] cursor, _ in
                self?.nextCursor = cursor.nextCursor
                self?.hasMore = cursor.hasMore
            })
            .flatMap { cursor, bookmarkFolder -> Observable<Mutation> in
                let bookmarkTitle = bookmarkFolder.name
                let bookmarkDescription = bookmarkFolder.introduction
                
                return .merge([
                    .just(.setBookmarkTitle(bookmarkTitle)),
                    .just(.setBookmarkDescription(bookmarkDescription)),
                    .just(.setUser(bookmarkFolder.user)),
                    .just(.setTotalCount(cursor.totalCount)),
                    .just(.appendStores(bookmarkFolder.bookmarks))
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == self.currentState.stores.count - 1 && self.hasMore
    }
}
