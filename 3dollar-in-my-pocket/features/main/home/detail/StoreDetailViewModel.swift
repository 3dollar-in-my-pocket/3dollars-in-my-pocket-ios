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
  let reviewService: ReviewServiceProtocol
  var currentLocation: (Double, Double) = (0, 0)
  
  var store: Store!
  
  struct Input {
    let currentLocation = PublishSubject<(Double, Double)>()
    let tapDeleteRequest = PublishSubject<Void>()
    let tapShare = PublishSubject<Void>()
    let tapTransfer = PublishSubject<Void>()
    let tapModify = PublishSubject<Void>()
    let tapWriteReview = PublishSubject<Void>()
    let tapModifyReview = PublishSubject<Review>()
    let tapPhoto = PublishSubject<Int>()
    let registerPhoto = PublishSubject<UIImage>()
    let deleteReview = PublishSubject<Int>()
  }
  
  struct Output {
    let store = PublishRelay<[StoreSection]>()
    let showDeleteModal = PublishRelay<Int>()
    let goToModify = PublishRelay<Store>()
    let showPhotoDetail = PublishRelay<(Int, [Image])>()
    let goToPhotoList = PublishRelay<[Image]>()
    let showReviewModal = PublishRelay<(Int, Review?)>()
    let showLoading = PublishRelay<Bool>()
  }
  
  init(
    storeId: Int,
    userDefaults: UserDefaultsUtil,
    storeService: StoreServiceProtocol,
    reviewService: ReviewServiceProtocol
  ) {
    self.storeId = storeId
    self.userDefaults = userDefaults
    self.storeService = storeService
    self.reviewService = reviewService
    super.init()
    
    self.input.currentLocation
      .do(onNext: { self.currentLocation = $0 })
      .map { (self.storeId, $0) }
      .bind(onNext: self.fetchStore)
      .disposed(by: disposeBag)
    
    self.input.tapDeleteRequest
      .map { self.storeId }
      .bind(to: self.output.showDeleteModal)
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
      .map { (self.storeId, nil) }
      .bind(to: self.output.showReviewModal)
      .disposed(by: disposeBag)
    
    self.input.tapModifyReview
      .map { (self.storeId, $0) }
      .bind(to: self.output.showReviewModal)
      .disposed(by: disposeBag)
    
    self.input.tapPhoto
      .bind(onNext: self.onTapPhoto(index:))
      .disposed(by: disposeBag)
    
    self.input.registerPhoto
      .map { (self.storeId, [$0]) }
      .bind(onNext: self.savePhoto)
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
    self.output.showLoading.accept(true)
    self.reviewService.deleteRevie(reviewId: reviewId)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          
          for reviewIndex in self.store.reviews.indices {
            if self.store.reviews[reviewIndex].id == reviewId {
              self.store.reviews.remove(at: reviewIndex)
              break
            }
          }
          
          self.output.store.accept([
            StoreSection(store: self.store, items: [nil]),
            StoreSection(store: self.store, items: [nil]),
            StoreSection(store: self.store, items: [nil]),
            StoreSection(store: self.store, items: [nil]),
            StoreSection(store: self.store, items: [nil] + self.store.reviews)
          ])
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
      ).disposed(by: self.disposeBag)
  }
  
  private func savePhoto(storeId: Int, photos: [UIImage]) {
    self.output.showLoading.accept(true)
    self.storeService.savePhoto(storeId: storeId, photos: photos)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          
          self.fetchStore(storeId: self.storeId, location: self.currentLocation)
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError{
            self.httpErrorAlert.accept(httpError)
          }
          self.output.showLoading.accept(false)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func onTapPhoto(index: Int) {
    if index == 3 {
      self.output.goToPhotoList.accept(self.store.images)
    } else {
      self.output.showPhotoDetail.accept((index, self.store.images))
    }
  }
}
