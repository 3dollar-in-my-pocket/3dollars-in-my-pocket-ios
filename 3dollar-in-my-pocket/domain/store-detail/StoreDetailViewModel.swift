import RxSwift
import RxCocoa
import KakaoSDKLink
import KakaoSDKTemplate

class StoreDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  var model = Model()
  
  let storeId: Int
  let userDefaults: UserDefaultsUtil
  let storeService: StoreServiceProtocol
  let reviewService: ReviewServiceProtocol
  
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
    let popup = PublishSubject<Void>()
  }
  
  struct Output {
    let store = PublishRelay<Store>()
    let category = PublishRelay<StoreCategory>()
    let showDeleteModal = PublishRelay<Int>()
    let goToModify = PublishRelay<Store>()
    let showPhotoDetail = PublishRelay<(Int, Int, [Image])>()
    let goToPhotoList = PublishRelay<Int>()
    let showReviewModal = PublishRelay<(Int, Review?)>()
    let showLoading = PublishRelay<Bool>()
    let popup = PublishRelay<Store>()
  }
  
  struct Model {
    var currentLocation: (Double, Double) = (0, 0)
    var store: Store?
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
  }
  
  override func bind() {
    self.input.currentLocation
      .do(onNext: { self.model.currentLocation = $0 })
      .map { (self.storeId, $0) }
      .bind(onNext: self.fetchStore)
      .disposed(by: disposeBag)
    
    self.input.tapDeleteRequest
      .map { self.storeId }
      .bind(to: self.output.showDeleteModal)
      .disposed(by: disposeBag)
    
    self.input.tapShare
      .compactMap { self.model.store }
      .bind(onNext: self.shareToKakao(store:))
      .disposed(by: disposeBag)
    
    self.input.tapTransfer
      .bind(onNext: self.goToToss)
      .disposed(by: disposeBag)
    
    self.input.tapModify
      .compactMap { self.model.store }
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
    
    self.input.popup
      .compactMap { self.model.store }
      .bind(to: self.output.popup)
      .disposed(by: disposeBag)
  }
  
  func clearKakaoLinkIfExisted() {
    if self.userDefaults.getDetailLink() != 0 {
      self.userDefaults.setDetailLink(storeId: 0)
    }
  }
  
  private func fetchStore(storeId: Int, location: (latitude: Double, longitude: Double)) {
    self.showLoading.accept(true)
    self.storeService.getStoreDetail(
      storeId: storeId,
      latitude: location.latitude,
      longitude: location.longitude
    )
    .map(Store.init)
    .subscribe(
      onNext: { [weak self] store in
        guard let self = self else { return }
        
        self.model.store = store
        let storeSections = [
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil]),
          StoreSection(store: store, items: [nil] + store.reviews)
        ]
        
        self.output.category.accept(store.categories[0])
        self.output.store.accept(store)
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
      androidExecutionParams: ["storeId": String(store.storeId)],
      iosExecutionParams: ["storeId": String(store.storeId)]
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
    let tossScheme = Bundle.main.object(forInfoDictionaryKey: "Toss scheme") as? String ?? ""
    guard let url = URL(string: tossScheme) else { return }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  private func deleteReview(reviewId: Int) {
    self.output.showLoading.accept(true)
    self.reviewService.deleteRevie(reviewId: reviewId)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          guard var store = self.model.store else { return }
          
          for reviewIndex in store.reviews.indices {
            if store.reviews[reviewIndex].reviewId == reviewId {
              store.reviews.remove(at: reviewIndex)
              break
            }
          }
          
          self.model.store?.reviews = store.reviews
//          self.output.store.accept([
//            StoreSection(store: store, items: [nil]),
//            StoreSection(store: store, items: [nil]),
//            StoreSection(store: store, items: [nil]),
//            StoreSection(store: store, items: [nil]),
//            StoreSection(store: store, items: [nil] + store.reviews)
//          ])
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
          
          self.fetchStore(storeId: self.storeId, location: self.model.currentLocation)
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError{
            self.httpErrorAlert.accept(httpError)
          }
          if let commonError = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: commonError.description)
            
            self.showSystemAlert.accept(alertContent)
          }
          self.output.showLoading.accept(false)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func onTapPhoto(index: Int) {
    guard let store = self.model.store else { return }
    if index == 3 {
      self.output.goToPhotoList.accept(self.storeId)
    } else {
      if !store.images.isEmpty {
        self.output.showPhotoDetail.accept((self.storeId, index, store.images))
      }
    }
  }
}
