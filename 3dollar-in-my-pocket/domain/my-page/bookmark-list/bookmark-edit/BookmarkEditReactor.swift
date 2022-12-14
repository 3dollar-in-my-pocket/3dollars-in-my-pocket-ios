import ReactorKit
import RxSwift

final class BookmarkEditReactor: BaseReactor, Reactor {
    enum Action {
        case didEndEditTitle(String)
        case didEndEditDescription(String)
        case tapSave
    }
    
    enum Mutation {
        case setTitle(String)
        case setDescription(String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
        case pop
    }
    
    struct State {
        var bookmarkFolder: BookmarkFolder
        @Pulse var showLading: Bool?
        @Pulse var showErrorAlert: Error?
        @Pulse var pop: Void?
    }
    
    let initialState: State
    private let bookmarkService: BookmarkServiceProtocol
    private let globalState: GlobalState
    
    init(
        bookmarkFolder: BookmarkFolder,
        bookmarkService: BookmarkServiceProtocol,
        globalState: GlobalState
    ) {
        self.bookmarkService = bookmarkService
        self.globalState = globalState
        self.initialState = State(bookmarkFolder: bookmarkFolder)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didEndEditTitle(let title):
            return .just(.setTitle(title))
            
        case .didEndEditDescription(let description):
            return .just(.setDescription(description))
            
        case .tapSave:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.editBookmarkFolder(),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTitle(let title):
            newState.bookmarkFolder.name = title
            
        case .setDescription(let description):
            newState.bookmarkFolder.introduction = description
            
        case .pop:
            newState.pop = ()
            
        case .showLoading(let isShow):
            newState.showLading = isShow
            
        case .showErrorAlert(let error):
            newState.showErrorAlert = error
        }
        
        return newState
    }
    
    private func editBookmarkFolder() -> Observable<Mutation> {
        return self.bookmarkService.editBookmarkFolder(
            introduction: self.currentState.bookmarkFolder.introduction,
            name: self.currentState.bookmarkFolder.name
        )
        .do(onNext: { [weak self] _ in
            guard let bookmarkFolder = self?.currentState.bookmarkFolder else { return }
            
            self?.globalState.updateBookmarkFolder.onNext(bookmarkFolder)
        })
        .map { _ in .pop }
        .catch { .just(.showErrorAlert($0)) }
    }
}
