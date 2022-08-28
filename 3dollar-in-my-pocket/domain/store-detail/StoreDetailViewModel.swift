import UIKit

import RxSwift
import RxCocoa
import KakaoSDKShare
import KakaoSDKTemplate

class StoreDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  var model = Model()
  
  let storeId: Int
  var userDefaults: UserDefaultsUtil
  let locationManager: LocationManagerProtocol
  let storeService: StoreServiceProtocol
  let reviewService: ReviewServiceProtocol
  
  struct Input {
    let fetch = PublishSubject<Void>()
    let tapDeleteRequest = PublishSubject<Void>()
    let tapShareButton = PublishSubject<Void>()
    let tapVisitHistoryButton = PublishSubject<Void>()
    let tapEditStoreButton = PublishSubject<Void>()
    let tapAddPhotoButton = PublishSubject<Void>()
    let tapWriteReview = PublishSubject<Void>()
    let tapEditReview = PublishSubject<Review>()
    let tapPhoto = PublishSubject<Int>()
    let registerPhoto = PublishSubject<UIImage>()
    let deleteReview = PublishSubject<Int>()
    let popup = PublishSubject<Void>()
    let tapVisitButton = PublishSubject<Void>()
  }
  
  struct Output {
    let store = PublishRelay<Store>()
    let reviews = PublishRelay<[Review?]>()
    let showDeleteModal = PublishRelay<Int>()
    let goToModify = PublishRelay<Store>()
    let showVisitHistories = PublishSubject<[VisitHistory]>()
    let showPhotoDetail = PublishRelay<(Int, Int, [Image])>()
    let showAddPhotoActionSheet = PublishRelay<Int>()
    let goToPhotoList = PublishRelay<Int>()
    let showReviewModal = PublishRelay<(Int, Review?)>()
    let popup = PublishRelay<Store>()
    let showVisit = PublishRelay<Store>()
  }
  
  struct Model {
    var currentLocation: (Double, Double) = (0, 0)
    var store: Store?
  }
  
  init(
    storeId: Int,
    userDefaults: UserDefaultsUtil,
    locationManager: LocationManagerProtocol,
    storeService: StoreServiceProtocol,
    reviewService: ReviewServiceProtocol
  ) {
    self.storeId = storeId
    self.userDefaults = userDefaults
    self.locationManager = locationManager
    self.storeService = storeService
    self.reviewService = reviewService
    super.init()
  }
  
  override func bind() {
    self.input.fetch
      .flatMap(self.locationManager.getCurrentLocation)
      .do { [weak self] location in
        self?.model.currentLocation = (location.coordinate.latitude, location.coordinate.longitude)
      }
      .compactMap { [weak self] _ -> (Int, (Double, Double)) in
        guard let self = self else { throw CommonError.init(desc: "self is nil") }
        
        return (self.storeId, self.model.currentLocation)
      }
      .bind(onNext: self.fetchStore)
      .disposed(by: self.disposeBag)
    
    self.input.tapDeleteRequest
      .map { self.storeId }
      .bind(to: self.output.showDeleteModal)
      .disposed(by: disposeBag)
    
    self.input.tapShareButton
      .compactMap { self.model.store }
      .bind(onNext: self.shareToKakao(store:))
      .disposed(by: disposeBag)
    
    self.input.tapVisitHistoryButton
        .compactMap { [weak self] in self?.model.store?.visitHistories }
        .bind(to: self.output.showVisitHistories)
        .disposed(by: self.disposeBag)
    
    self.input.tapEditStoreButton
      .compactMap { self.model.store }
      .bind(to: self.output.goToModify)
      .disposed(by: disposeBag)
    
    self.input.tapAddPhotoButton
      .compactMap { [weak self] in
        return self?.storeId
      }
      .bind(to: self.output.showAddPhotoActionSheet)
      .disposed(by: self.disposeBag)
    
    self.input.tapWriteReview
      .map { (self.storeId, nil) }
      .bind(to: self.output.showReviewModal)
      .disposed(by: disposeBag)
    
    self.input.tapEditReview
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
    
    self.input.tapVisitButton
      .compactMap { [weak self] in
        self?.model.store
      }
      .bind(to: self.output.showVisit)
      .disposed(by: self.disposeBag)
  }
  
  func clearKakaoLinkIfExisted() {
      if !self.userDefaults.shareLink.isEmpty {
          self.userDefaults.shareLink = ""
      }
  }
  
  private func fetchStore(
    storeId: Int,
    location: (latitude: Double, longitude: Double)
    ) {
    self.showLoading.accept(true)
    self.storeService.getStoreDetail(
      storeId: storeId,
      latitude: location.latitude,
      longitude: location.longitude,
      startDate: Date().addMonth(month: -1),
      endDate: Date()
    )
    .map(Store.init)
    .subscribe(
      onNext: { [weak self] store in
        guard let self = self else { return }
        
        self.model.store = store
        self.output.store.accept(store)
        self.output.reviews.accept([nil] + store.reviews)
        self.showLoading.accept(false)
      },
      onError: { [weak self] error in
        self?.showErrorAlert.accept(error)
        self?.showLoading.accept(false)
      }
    )
    .disposed(by: self.disposeBag)
  }
  
  private func shareToKakao(store: Store) {
    let urlString = "https://map.kakao.com/link/map/\(store.storeName),\(store.latitude),\(store.longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let webURL = URL(string: urlString)
    let link = Link(
      webUrl: webURL,
      mobileWebUrl: webURL,
      androidExecutionParams: [
          "storeId": String(store.id),
          "storeType": "streetFood"
      ],
      iosExecutionParams: [
          "storeId": String(store.id),
          "storeType": "streetFood"
      ]
    )
    let content = Content(
      title: "store_detail_share_title".localized,
      imageUrl: URL(string: "https://storage.threedollars.co.kr/share/share-with-kakao.png")!,
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
    
      ShareApi.shared.shareDefault(templatable: feedTemplate) { linkResult, error in
          if let error = error {
              self.showErrorAlert.accept(error)
          } else {
              if let linkResult = linkResult {
                  UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
              }
          }
      }
  }
    
  private func deleteReview(reviewId: Int) {
    self.showLoading.accept(true)
    self.reviewService.deleteReview(reviewId: reviewId)
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
          self.output.reviews.accept(store.reviews)
          self.showLoading.accept(false)
        },
        onError: { [weak self] error in
          self?.showErrorAlert.accept(error)
          self?.showLoading.accept(false)
        }
      ).disposed(by: self.disposeBag)
  }
  
    private func savePhoto(storeId: Int, photos: [UIImage]) {
        self.showLoading.accept(true)
        self.storeService.savePhoto(storeId: storeId, photos: photos)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }

                self.fetchStore(storeId: self.storeId, location: self.model.currentLocation)
                self.showLoading.accept(false)
            }, onError: { [weak self] error in
                self?.showErrorAlert.accept(error)
                self?.showLoading.accept(false)
            })
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
  
  private func extractPhotos(from photos: [Image]) -> [Image?] {
    if photos.isEmpty {
      return [nil]
    } else if photos.count <= 4 {
      return Array(photos[0..<photos.count])
    } else {
      return Array(photos[0..<4])
    }
  }
}
