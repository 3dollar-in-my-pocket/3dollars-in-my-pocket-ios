import RxSwift
import RxCocoa

class RegisteredStoreViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  
  var stores: [Store] = [] {
    didSet {
      self.output.stores.accept(stores)
    }
  }
  var totalCount = 0
  var totalPage = 0
  var currentPage = 1
  
  struct Input {
    let tapStore = PublishSubject<Int>()
    let loadMore = PublishSubject<Int>()
  }
  
  struct Output {
    let stores = PublishRelay<[Store]>()
    let isHiddenFooter = PublishRelay<Bool>()
    let goToStoreDetail = PublishRelay<Int>()
  }
  
  init(storeService: StoreServiceProtocol) {
    self.storeService = storeService
    super.init()
    
    self.input.tapStore
      .map { self.stores[$0].id }
      .bind(to: self.output.goToStoreDetail)
      .disposed(by: disposeBag)
    
    self.input.loadMore
      .filter { self.stores.count - 1 == $0 && self.currentPage < self.totalPage }
      .do { [weak self] _ in
        guard let self = self else { return }
        self.currentPage = self.currentPage + 1
      }
      .map { _ in Void() }
      .bind(onNext: self.fetchRegisteredStores)
      .disposed(by: disposeBag)
  }
  
  func fetchRegisteredStores() {
    self.output.isHiddenFooter.accept(false)
    self.storeService.getReportedStore(page: currentPage)
      .subscribe { [weak self] pageStore in
        guard let self = self else { return }
        self.totalCount = pageStore.totalElements
        self.totalPage = pageStore.totalPages
        self.stores = self.stores + pageStore.content
        self.output.isHiddenFooter.accept(true)
      } onError: { error in
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        }
        self.output.isHiddenFooter.accept(true)
      }
      .disposed(by: disposeBag)
  }
  
}
