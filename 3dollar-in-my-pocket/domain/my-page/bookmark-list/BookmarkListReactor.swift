import ReactorKit
import RxSwift
import RxCocoa

final class BookmarkListReactor: Reactor {
    enum Action {
        case viewDidLoad
        case tapEditOverview
        case tapDeleteMode
        case tapDeleteAll
        case tapDelete(row: Int)
        case tapFinish
        case tapStore(row: Int)
    }
    
    enum Mutation {
        case setBookmarkFolder(BookmarkFolder)
    }
    
    struct State {
        var bookmarkFolder: BookmarkFolder?
        @Pulse var pushStoreDetail: StoreProtocol?
        @Pulse var showLoading: Bool?
        @Pulse var showErrorAlert: Error?
    }
    
    let initialState: State
    private let bookmarkService: BookmarkServiceProtocol
    
    init(
        bookmarkService: BookmarkServiceProtocol,
        state: State = State()
    ) {
        self.bookmarkService = bookmarkService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            
        }
    }
}
