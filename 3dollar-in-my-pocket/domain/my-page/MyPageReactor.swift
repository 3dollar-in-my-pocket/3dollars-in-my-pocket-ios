import ReactorKit
import RxSwift

final class MyPageReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapMyMedal
        case tapVisitHistory(row: Int)
        case tapBookmark(row: Int)
    }
    
    enum Mutation {
        case setUser(User)
        case showErrorAlert(Error)
    }
    
    struct State {
        var user: User
        var visitHistories: [VisitHistory]
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
        state: State = State(user: User(), visitHistories: [])
    ) {
        self.userService = userService
        self.visitHistoryService = visitHistoryService
        self.bookmarkService = bookmarkService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            
        }
    }
    
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let tapMyMedal = PublishSubject<Void>()
        let onChangeMedal = PublishSubject<Medal>()
        let tapNickname = PublishSubject<Void>()
        let tapVisitHistory = PublishSubject<Int>()
    }
    
    struct Output {
        let user = PublishRelay<User>()
        let visitHistories = PublishRelay<[VisitHistory]>()
        let isRefreshing = PublishRelay<Bool>()
        let goToStoreDetail = PublishRelay<Int>()
        let goToMyMedal = PublishRelay<Medal>()
        let goToRename = PublishRelay<String>()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .bind { [weak self] in
                self?.fetchMyActivityInfo()
                self?.fetchVisitHistories()
            }
            .disposed(by: self.disposeBag)
        
        self.input.tapMyMedal
            .withLatestFrom(self.output.user) { $1.medal }
            .bind(to: self.output.goToMyMedal)
            .disposed(by: self.disposeBag)
        
        self.input.onChangeMedal
            .withLatestFrom(self.output.user) { ($0, $1) }
            .bind(onNext: { [weak self] (newMedal, user) in
                var updatedUser = user
                updatedUser.medal = newMedal
                
                self?.output.user.accept(updatedUser)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapNickname
            .withLatestFrom(self.output.user) { $1.name }
            .bind(to: self.output.goToRename)
            .disposed(by: self.disposeBag)
        
        self.input.tapVisitHistory
            .withLatestFrom(self.output.visitHistories) { $1[$0] }
            .filter { !$0.store.isDeleted }
            .map { $0.storeId }
            .bind(to: self.output.goToStoreDetail)
            .disposed(by: self.disposeBag)
    }
    
    private func fetchMyActivityInfo() -> Observable<Mutation> {
        return self.userService.fetchUserActivity()
            .map { .setUser($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchVisitHistories() {
        self.visitHistoryService.fetchVisitHistory(cursor: nil, size: self.size)
            .map { $0.contents.map { VisitHistory(response: $0) } }
            .subscribe(
                onNext: { [weak self] visitHistories in
                    self?.output.visitHistories.accept(visitHistories)
                    self?.output.isRefreshing.accept(false)
                },
                onError: { [weak self] error in
                    self?.showErrorAlert.accept(error)
                    self?.output.isRefreshing.accept(false)
                }
            )
            .disposed(by: self.disposeBag)
    }
}
