import RxSwift
import RxCocoa
import CoreLocation

class RegisteredStoreViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  let userDefaults: UserDefaultsUtil
  
  var stores: [StoreCard] = [] {
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
    let stores = PublishRelay<[StoreCard]>()
    let isHiddenFooter = PublishRelay<Bool>()
    let goToStoreDetail = PublishRelay<Int>()
  }
  
  
  init(
    storeService: StoreServiceProtocol,
    userDefaults: UserDefaultsUtil
  ) {
    self.storeService = storeService
    self.userDefaults = userDefaults
    super.init()
    
    self.input.tapStore
      .map { self.stores[$0].id }
      .bind(to: self.output.goToStoreDetail)
      .disposed(by: disposeBag)
    
    self.input.loadMore
      .filter { self.stores.count - 1 == $0 && self.currentPage < self.totalPage }
      .do { [weak self] _ in
        guard let self = self else { return }
        self.currentPage += 1
      }
      .map { _ in Void() }
      .bind(onNext: self.searchRegisteredStores)
      .disposed(by: disposeBag)
  }
  
  func searchRegisteredStores() {
    let currentLocation = self.userDefaults.getUserCurrentLocation()
    
    self.output.isHiddenFooter.accept(false)
    self.storeService.searchRegisteredStores(
      latitude: currentLocation.coordinate.latitude,
      longitude: currentLocation.coordinate.longitude,
      page: self.currentPage
    )
    .subscribe(
      onNext: { [weak self] pageStore in
        guard let self = self else { return }
        self.totalCount = pageStore.totalElements
        self.totalPage = pageStore.totalPages
        self.stores += pageStore.content
        self.output.isHiddenFooter.accept(true)
      },
      onError: { error in
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        }
        if let commonError = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: commonError.description)
          
          self.showSystemAlert.accept(alertContent)
        }
        self.output.isHiddenFooter.accept(true)
      }
    )
    .disposed(by: disposeBag)
  }
}
