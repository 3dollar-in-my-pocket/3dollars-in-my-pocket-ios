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
        case updateBookmarkFolder(BookmarkFolder)
        case setTotalCount(Int)
        case decreaseTotalCount
        case toggleDeleteMode
        case pushEditBookmarkFolder
        case clearBookmakrs
        case deleteBookamrk(storeId: String)
        case pushStoreDetail(storeId: String)
        case pushFoodTruckDetail(storeId: String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var bookmarkFolder: BookmarkFolder
        var totalCount: Int?
        var isDeleteMode: Bool
        @Pulse var pushStoreDetail: String?
        @Pulse var pushFoodtruckDetail: String?
        @Pulse var pushEditBookmarkFolder: BookmarkFolder?
    }
    
    let initialState: State
    private let bookmarkService: BookmarkServiceProtocol
    private let globalState: GlobalState
    private var cursor: String?
    private var hasMore: Bool
    
    init(
        bookmarkService: BookmarkServiceProtocol,
        globalState: GlobalState,
        hasMore: Bool = true,
        state: State = State(
            bookmarkFolder: BookmarkFolder(),
            isDeleteMode: false
        )
    ) {
        self.bookmarkService = bookmarkService
        self.globalState = globalState
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
            guard !self.currentState.bookmarkFolder.bookmarks.isEmpty else { return .empty() }
            
            return self.clearBookamrks()
            
        case .tapDelete(let row):
            return self.deleteBookamrk(row: row)
            
        case .tapFinish:
            return .just(.toggleDeleteMode)
            
        case .tapStore(let row):
            guard !self.currentState.isDeleteMode else { return .empty() }
            let tappedStore = self.currentState.bookmarkFolder.bookmarks[row]
            
            switch tappedStore.storeCategory {
            case .streetFood:
                return .just(.pushStoreDetail(storeId: tappedStore.id))
                
            case .foodTruck:
                return .just(.pushFoodTruckDetail(storeId: tappedStore.id))
                
            case .unknown:
                return .empty()
            }
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.deleteBookmarkStore
                .flatMap { storeIds -> Observable<Mutation> in
                    return .merge(storeIds.map { .merge([
                        .just(.deleteBookamrk(storeId: $0)),
                        .just(.decreaseTotalCount)
                    ]) })
                },
            self.globalState.updateBookmarkFolder
                .map { .updateBookmarkFolder($0) }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBookmarkFolder(let bookmarkFolder):
            newState.bookmarkFolder = bookmarkFolder
            
        case .updateBookmarkFolder(let bookmarkFolder):
            newState.bookmarkFolder.introduction = bookmarkFolder.introduction
            newState.bookmarkFolder.name = bookmarkFolder.name
            
        case .setTotalCount(let count):
            newState.totalCount = count
            
        case .decreaseTotalCount:
            guard let totalCount = newState.totalCount else { break }
            
            newState.totalCount = totalCount - 1
            
        case .toggleDeleteMode:
            newState.isDeleteMode.toggle()
            
        case .pushEditBookmarkFolder:
            newState.pushEditBookmarkFolder = newState.bookmarkFolder
            
        case .clearBookmakrs:
            newState.bookmarkFolder.bookmarks = []
            
        case .deleteBookamrk(let storeId):
            if let targetIndex = newState.bookmarkFolder.bookmarks.firstIndex(where: {
                $0.id == storeId
            }) {
                newState.bookmarkFolder.bookmarks.remove(at: targetIndex)
            }
            
        case .pushStoreDetail(let storeId):
            newState.pushStoreDetail = storeId
            
        case .pushFoodTruckDetail(let storeId):
            newState.pushFoodtruckDetail = storeId
            
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
    
    private func deleteBookamrk(row: Int) -> Observable<Mutation> {
        let store = self.currentState.bookmarkFolder.bookmarks[row]
        
        return self.bookmarkService.unBookmarkStore(
            storeType: store.storeCategory,
            storeId: store.id
        )
        .do(onNext: { [weak self] _ in
            self?.globalState.deleteBookmarkStore.onNext([store.id])
        })
        .flatMap { _ -> Observable<Mutation> in
            return .merge([
                .just(.decreaseTotalCount)
            ])
        }
        .catch { .just(.showErrorAlert($0)) }
    }
    
    private func clearBookamrks() -> Observable<Mutation> {
        return self.bookmarkService.clearBookmarks()
            .do(onNext: { [weak self] _ in
                self?.globalState.deleteBookmarkStore
                    .onNext(self?.currentState.bookmarkFolder.bookmarks.map { $0.id } ?? [])
            })
            .flatMap { _ -> Observable<Mutation> in
                return .merge([
                    .just(.setTotalCount(0)),
                    .just(.toggleDeleteMode)
                ])
            }
            .catch { .just(.showErrorAlert($0)) }
    }
}
