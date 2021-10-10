import RxSwift
import RxCocoa

class MyPageViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let userService: UserServiceProtocol
  let storeService: StoreServiceProtocol
  let reviewService: ReviewServiceProtocol
  
  struct Input {
    let tapStore = PublishSubject<Int>()
    let tapReview = PublishSubject<Int>()
  }
  
  struct Output {
    let user = PublishRelay<User>()
    let registeredStoreCount = PublishRelay<Int>()
    let registeredStores = PublishRelay<[Store?]>()
    let reviewCount = PublishRelay<Int>()
    let reviews = PublishRelay<[Review?]>()
    let goToStoreDetail = PublishRelay<Int>()
    let goToRegistered = PublishRelay<Void>()
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  
  init(
    userService: UserServiceProtocol,
    storeService: StoreServiceProtocol,
    reviewService: ReviewServiceProtocol
  ) {
    self.userService = userService
    self.storeService = storeService
    self.reviewService = reviewService
    super.init()
    
    self.input.tapStore
      .withLatestFrom(self.output.registeredStores) { $1[$0] }
      .bind(onNext: { [weak self] store in
        guard let self = self else { return }
        if let store = store {
          self.output.goToStoreDetail.accept(store.storeId)
        } else {
          self.output.goToRegistered.accept(())
        }
      })
      .disposed(by: disposeBag)
    
    self.input.tapReview
      .withLatestFrom(self.output.reviews) { $1[$0] }
      .compactMap { $0?.storeId }
      .bind(to: self.output.goToStoreDetail)
      .disposed(by: disposeBag)
  }
  
  func fetchMyInfo() {
    self.userService.fetchUserInfo()
      .map(User.init)
      .subscribe(
        onNext: self.output.user.accept,
        onError: self.showErrorAlert.accept(_:)
      )
      .disposed(by: disposeBag)
  }
  
  func fetchReportedStore() {
    self.storeService.getReportedStore(currentLocation: nil, totalCount: nil, cursor: nil)
      .subscribe(
        onNext: { [weak self] pagination in
          guard let self = self else { return }
          let stores = pagination.contents.map(Store.init)
          
          self.output.registeredStoreCount.accept(pagination.totalElements)
          if pagination.contents.count > 5 {
            let sliceArray: [Store?] = Array(stores[0...4]) + [nil]
            
            self.output.registeredStores.accept(sliceArray)
          } else if pagination.contents.isEmpty {
            self.output.registeredStores.accept(stores)
          } else {
            self.output.registeredStores.accept(stores + [nil])
          }
        },
        onError: self.showErrorAlert.accept(_:)
      )
      .disposed(by: disposeBag)
  }
  
  func fetchMyReview() {
    self.reviewService.fetchMyReview(totalCount: nil, cursor: nil)
      .subscribe(
        onNext: { [weak self] pagination in
          guard let self = self else { return }
          
          self.output.reviewCount.accept(pagination.totalElements)
          if pagination.totalElements > 3 {
            let reviews = Array(pagination.contents[0...2]).map(Review.init)
            
            self.output.reviews.accept(reviews)
          } else {
            var reviews: [Review?] = pagination.contents.map(Review.init)
            
            while reviews.count != 3 {
              reviews.append(nil)
            }
            self.output.reviews.accept(reviews)
          }
        },
        onError: self.showErrorAlert.accept(_:)
      )
      .disposed(by: self.disposeBag)
  }
}
