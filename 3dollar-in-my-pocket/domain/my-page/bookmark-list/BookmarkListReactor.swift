import ReactorKit
import RxSwift
import RxCocoa

final class BookmarkListReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case willDisplayCell(row: Int)
        case tapEditOverview
        case tapDeleteMode
        case tapDeleteAll
        case tapDelete(row: Int)
        case tapFinish
        case tapStore(row: Int)
    }
    
    enum Mutation {
        case setBookmarkFolder(BookmarkFolder)
        case setTotalCount(Int)
        case toggleDeleteMode
        case pushEditBookmarkFolder
        case clearBookmakrs
        case removeBookmark(row: Int)
        case addWillDeleteStores([StoreProtocol])
        case pushStoreDetail(storeId: String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var bookmarkFolder: BookmarkFolder
        var totalCount: Int?
        var isDeleteMode: Bool
        var willDeleteStore: [StoreProtocol]
        @Pulse var pushStoreDetail: String?
        @Pulse var pushEditBookmarkFolder: BookmarkFolder?
    }
    
    let initialState: State
    private let bookmarkService: BookmarkServiceProtocol
    private var cursor: String?
    private var hasMore: Bool
    
    init(
        bookmarkService: BookmarkServiceProtocol,
        hasMore: Bool = true,
        state: State = State(
            bookmarkFolder: BookmarkFolder(),
            isDeleteMode: false,
            willDeleteStore: []
        )
    ) {
        self.bookmarkService = bookmarkService
        self.initialState = state
        self.hasMore = hasMore
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.fetchBookmarks(),
                .just(.showLoading(isShow: false))
            ])
            
        case .willDisplayCell(let row):
            guard self.canFetchNextPage(row: row) else { return .empty() }
            
            return self.fetchBookmarks()
            
        case .tapEditOverview:
            return .just(.pushEditBookmarkFolder)
            
        case .tapDeleteMode:
            return .just(.toggleDeleteMode)
            
        case .tapDeleteAll:
            return .merge([
                .just(.clearBookmakrs),
                .just(.addWillDeleteStores(self.currentState.bookmarkFolder.bookmarks))
            ])
            
        case .tapDelete(let row):
            return .merge([
                .just(.addWillDeleteStores([self.currentState.bookmarkFolder.bookmarks[row]])),
                .just(.removeBookmark(row: row))
            ])
            
        case .tapFinish:
            guard !self.currentState.willDeleteStore.isEmpty else {
                return .just(.toggleDeleteMode)
            }
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.deleteBookmark(stores: self.currentState.willDeleteStore),
                .just(.showLoading(isShow: false))
            ])
            
        case .tapStore(let row):
            let tappedStore = self.currentState.bookmarkFolder.bookmarks[row]
            
            return .just(.pushStoreDetail(storeId: tappedStore.id))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBookmarkFolder(let bookmarkFolder):
            newState.bookmarkFolder = bookmarkFolder
            
        case .setTotalCount(let count):
            newState.totalCount = count
            
        case .toggleDeleteMode:
            newState.isDeleteMode.toggle()
            newState.willDeleteStore.removeAll()
            
        case .pushEditBookmarkFolder:
            newState.pushEditBookmarkFolder = newState.bookmarkFolder
            
        case .clearBookmakrs:
            newState.bookmarkFolder.bookmarks = []
            
        case .removeBookmark(let row):
            newState.bookmarkFolder.bookmarks.remove(at: row)
            
        case .addWillDeleteStores(let stores):
            newState.willDeleteStore.append(contentsOf: stores)
            
        case .pushStoreDetail(let storeId):
            newState.pushStoreDetail = storeId
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchBookmarks() -> Observable<Mutation> {
        return self.bookmarkService.fetchMyBookmarks(cursor: self.cursor, size: 20)
            .do(onNext: { [weak self] cursor, _ in
                self?.hasMore = cursor.hasMore
                self?.cursor = cursor.nextCursor
            })
            .flatMap { cursor, bookmarkFolder -> Observable<Mutation> in
                return .merge([
                    .just(.setBookmarkFolder(bookmarkFolder)),
                    .just(.setTotalCount(cursor.totalCount))
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func canFetchNextPage(row: Int) -> Bool {
        return row == self.currentState.bookmarkFolder.bookmarks.count && self.hasMore
    }
    
    private func deleteBookmark(stores: [StoreProtocol]) -> Observable<Mutation> {
        let observables = stores.map {
            self.bookmarkService.unBookmarkStore(storeType: $0.storeCategory, storeId: $0.id)
        }
        
        return Observable.zip(observables)
            .map { _ in .toggleDeleteMode }
            .catch { .just(.showErrorAlert($0)) }
    }
}
