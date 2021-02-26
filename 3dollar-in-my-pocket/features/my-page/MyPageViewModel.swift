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
        if let store = store{
          self.output.goToStoreDetail.accept(store.id)
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
    self.userService.getUserInfo()
      .subscribe(
        onNext: self.output.user.accept,
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(
              title: nil,
              message: error.description
            )
            
            self.showSystemAlert.accept(alertContent)
          }
        }
      )
      .disposed(by: disposeBag)
  }
  
  func fetchReportedStore() {
    self.storeService.getReportedStore(page: 1)
      .subscribe(
        onNext: { [weak self] storePage in
          guard let self = self else { return }
          self.output.registeredStoreCount.accept(storePage.totalElements)
          
          if storePage.content.count > 5 {
            var sliceArray: [Store?] = Array(storePage.content[0...4])
            
            sliceArray.append(nil)
            self.output.registeredStores.accept(sliceArray)
          } else {
            self.output.registeredStores.accept(storePage.content)
          }
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.output.showSystemAlert.accept(alertContent)
          }
        }
      )
      .disposed(by: disposeBag)
  }
  
  func fetchMyReview() {
    self.reviewService.getMyReview(page: 1)
      .subscribe(
        onNext: { [weak self] reviewPage in
          guard let self = self else { return }
          
          self.output.reviewCount.accept(reviewPage.totalElements)
          if reviewPage.totalElements > 3 {
            self.output.reviews.accept(Array(reviewPage.content[0...2]))
          } else {
            var contents: [Review?] = reviewPage.content
            
            while contents.count != 3 {
              contents.append(nil)
            }
            self.output.reviews.accept(contents)
          }
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.output.showSystemAlert.accept(alertContent)
          }
        }
      )
      .disposed(by: disposeBag)
  }
}
