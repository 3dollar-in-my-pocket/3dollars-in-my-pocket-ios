import RxSwift
import RxCocoa

final class RegisteredStoreViewModel: BaseViewModel {
    
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let loadMore = PublishSubject<Int>()
        let tapStore = PublishSubject<Int>()
    }
    
    struct Output {
        let stores = BehaviorRelay<[Store]>(value: [])
        let totalStoreCount = PublishRelay<Int>()
        let isHiddenFooter = PublishRelay<Bool>()
        let goToStoreDetail = PublishRelay<Int>()
    }
    
    let input = Input()
    let output = Output()
    let storeService: StoreServiceProtocol
    let userDefaults: UserDefaultsUtil
    private let size = 20
    private var nextCursor: Int?
    
    
    init(
        storeService: StoreServiceProtocol,
        userDefaults: UserDefaultsUtil
    ) {
        self.storeService = storeService
        self.userDefaults = userDefaults
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.fetchRegisteredStores(nextCursor: self.nextCursor)
            })
            .disposed(by: self.disposeBag)
        
        self.input.loadMore
            .withLatestFrom(self.output.stores) { $0 >= $1.count }
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.canLoadMore(isUpperItemCounts: $0, nextCursor: self.nextCursor)
            }
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.fetchRegisteredStores(nextCursor: self.nextCursor)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapStore
            .withLatestFrom(self.output.stores) { $1[$0].storeId }
            .bind(to: self.output.goToStoreDetail)
            .disposed(by: self.disposeBag)
    }
    
    private func fetchRegisteredStores(nextCursor: Int?) {
        self.output.isHiddenFooter.accept(false)
        self.storeService.fetchRegisteredStores(cursor: self.nextCursor, size: self.size)
            .do(onNext: { [weak self] page in
                self?.nextCursor = page.nextCursor
                self?.output.totalStoreCount.accept(page.totalElements)
            })
            .map { $0.contents.map(Store.init) }
            .withLatestFrom(self.output.stores) { $1 + $0 }
            .subscribe(
                onNext: { [weak self] stores in
                    self?.output.isHiddenFooter.accept(true)
                    self?.output.stores.accept(stores)
                },
                onError: { [weak self] error in
                    self?.output.isHiddenFooter.accept(true)
                    self?.showErrorAlert.accept(error)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func canLoadMore(isUpperItemCounts: Bool, nextCursor: Int?) -> Bool {
        return isUpperItemCounts && self.nextCursor != nil
    }
}
