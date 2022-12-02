import RxSwift
import RxCocoa

final class MyPageViewModel: BaseViewModel {
    
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
