import RxSwift
import RxCocoa

final class RegisteredStoreViewModel: BaseViewModel {
    
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let loadMore = PublishSubject<Int>()
        let tapStore = PublishSubject<Int>()
    }
    
    struct Output {
        let storesPublisher = PublishRelay<[Store]>()
        let totalStoreCount = PublishRelay<Int>()
        let isHiddenFooter = PublishRelay<Bool>()
        let goToStoreDetail = PublishRelay<Int>()
        
        var stores: [Store] = [] {
            didSet {
                self.storesPublisher.accept(stores)
            }
        }
    }
    
    let input = Input()
    var output = Output()
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
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.canLoadMore(index: $0, nextCursor: self.nextCursor)
            }
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.fetchRegisteredStores(nextCursor: self.nextCursor)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapStore
            .compactMap { [weak self] in self?.output.stores[$0] }
            .filter { !$0.isDeleted }
            .map { $0.storeId }
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
            .subscribe(
                onNext: { [weak self] stores in
                    guard let self = self else { return }
                    
                    self.output.isHiddenFooter.accept(true)
                    self.output.stores.append(contentsOf: stores)
                },
                onError: { [weak self] error in
                    self?.output.isHiddenFooter.accept(true)
                    self?.showErrorAlert.accept(error)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func canLoadMore(index: Int, nextCursor: Int?) -> Bool {
        return index >= self.output.stores.count - 1 && self.nextCursor != nil
    }
}
