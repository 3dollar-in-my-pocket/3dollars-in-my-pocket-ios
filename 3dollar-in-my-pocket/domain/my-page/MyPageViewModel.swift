import RxSwift
import RxCocoa

final class MyPageViewModel: BaseViewModel {
    
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
    }
    
    struct Output {
        let user = PublishRelay<User>()
        let visitHistories = PublishRelay<[VisitHistory]>()
        let isRefreshing = PublishRelay<Bool>()
    }
    
    let input = Input()
    let output = Output()
    let userService: UserServiceProtocol
    let visitHistoryService: VisitHistoryServiceProtocol
    private let size = 5
    
    
    init(
        userService: UserServiceProtocol,
        visitHistoryService: VisitHistoryServiceProtocol
    ) {
        self.userService = userService
        self.visitHistoryService = visitHistoryService
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .bind { [weak self] in
                self?.fetchMyActivityInfo()
                self?.fetchVisitHistories()
            }
            .disposed(by: self.disposeBag)
    }
    
    private func fetchMyActivityInfo() {
        self.userService.fetchUserActivity()
            .map(User.init)
            .subscribe(
                onNext: { [weak self] user in
                    self?.output.user.accept(user)
                    self?.output.isRefreshing.accept(false)
                },
                onError: { [weak self] error in
                    self?.showErrorAlert.accept(error)
                    self?.output.isRefreshing.accept(false)
                }
            )
            .disposed(by: self.disposeBag)
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
