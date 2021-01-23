import RxSwift
import RxCocoa
import KakaoSDKLink
import KakaoSDKTemplate

class StoreDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let storeId: Int
  let userDefaults: UserDefaultsUtil
  let storeService: StoreServiceProtocol
  
  var store: Store!
  
  struct Input {
    let currentLocation = PublishSubject<(Double, Double)>()
    let tapShare = PublishSubject<Void>()
    let tapTransfer = PublishSubject<Void>()
    let tapModify = PublishSubject<Void>()
    let tapWriteReview = PublishSubject<Void>()
    let deleteReview = PublishSubject<Int>()
  }
  
  struct Output {
    let store = PublishRelay<[StoreSection]>()
    let goToModify = PublishRelay<Store>()
    let showReviewModal = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  init(
    storeId: Int,
    userDefaults: UserDefaultsUtil,
    storeService: StoreServiceProtocol
  ) {
    self.storeId = storeId
    self.userDefaults = userDefaults
    self.storeService = storeService
    super.init()
    
    self.input.currentLocation
      .map { (self.storeId, $0) }
      .bind(onNext: self.fetchStore)
      .disposed(by: disposeBag)
    
    self.input.tapShare
      .map { self.store }
      .bind(onNext: self.shareToKakao(store:))
      .disposed(by: disposeBag)
    
    self.input.tapTransfer
      .bind(onNext: self.goToToss)
      .disposed(by: disposeBag)
    
    self.input.tapModify
      .map { self.store }
      .bind(to: self.output.goToModify)
      .disposed(by: disposeBag)
    
    self.input.tapWriteReview
      .map { self.storeId }
      .bind(to: self.output.showReviewModal)
      .disposed(by: disposeBag)
    
    self.input.deleteReview
      .bind(onNext: self.deleteReview(reviewId:))
      .disposed(by: disposeBag)
  }
  
  func clearKakaoLinkIfExisted() {
    if self.userDefaults.getDetailLink() != 0 {
      self.userDefaults.setDetailLink(storeId: 0)
    }
  }
  
  private func fetchStore(storeId: Int, location: (latitude: Double, longitude: Double)) {
    self.storeService.getStoreDetail(
      storeId: storeId,
      latitude: location.latitude,
      longitude: location.longitude
    ).subscribe(
      onNext: { [weak self] store in
        guard let self = self else { return }
        self.store = store
        let storeSections = [
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil] + store.reviews)
        ]
        
        self.output.store.accept(storeSections)
        self.output.showLoading.accept(false)
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        } else if let error = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: error.description)
          
          self.showSystemAlert.accept(alertContent)
        }
        self.output.showLoading.accept(false)
      }
    )
    .disposed(by: disposeBag)
  }
  
  private func shareToKakao(store: Store) {
    let urlString = "https://map.kakao.com/link/map/\(store.storeName),\(store.latitude),\(store.longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let webURL = URL(string: urlString)
    let link = Link(
      webUrl: webURL,
      mobileWebUrl: webURL,
      androidExecutionParams: ["storeId": String(store.id)],
      iosExecutionParams: ["storeId": String(store.id)]
    )
    let content = Content(
      title: "store_detail_share_title".localized,
      imageUrl: URL(string: HTTPUtils.url + "/images/share-with-kakao.png")!,
      imageWidth: 500,
      imageHeight: 500,
      description: "store_detail_share_description".localized,
      link: link
    )
    let feedTemplate = FeedTemplate(
      content: content,
      social: nil,
      buttonTitle: nil,
      buttons: [Button(title: "store_detail_share_button".localized, link: link)]
    )
    
    LinkApi.shared.defaultLink(templatable: feedTemplate) { (linkResult, error) in
      if let error = error {
        let alertContent = AlertContent(title: "Error in Kakao link", message: error.localizedDescription)
        
        self.showSystemAlert.accept(alertContent)
      } else {
        if let linkResult = linkResult {
          UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
        }
      }
    }
  }
  
  private func goToToss() {
    guard let url = URL(string: "https://service.toss.im/transfer/bridge/open-transfer?type=send") else { return }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  private func deleteReview(reviewId: Int) {
//    self.output.showLoading.accept(true)
//    ReviewService().deleteRevie(reviewId: reviewId)
//      .subscribe(
//        onNext: { [weak self] _ in
//          guard let self = self else { return }
//          if var updatedStore = try? self.store.value() {
//            for reviewIndex in updatedStore.reviews.indices {
//              if updatedStore.reviews[reviewIndex].id == reviewId {
//                updatedStore.reviews.remove(at: reviewIndex)
//                break
//              }
//            }
//            self.store.onNext(updatedStore)
//          }
//          self.output.showLoading.accept(false)
//        },
//        onError: { [weak self] error in
//          guard let self = self else { return }
//          if let httpError = error as? HTTPError {
//            self.httpErrorAlert.accept(httpError)
//          } else if let error = error as? CommonError {
//            let alertContent = AlertContent(title: nil, message: error.description)
//
//            self.showSystemAlert.accept(alertContent)
//          }
//          self.output.showLoading.accept(false)
//        }
//      ).disposed(by: self.disposeBag)
  }
}
