import RxSwift
import RxCocoa
import KakaoSDKLink
import KakaoSDKTemplate

class DetailViewModel: BaseViewModel {
  
  var store = BehaviorSubject<Store?>.init(value: nil)
  var location: (latitude: Double, longitude: Double) = (0 , 0)
  let input = Input()
  let output = Output()
  let userDefaults: UserDefaultsUtil
  
  struct Input {
    let tapShare = PublishSubject<Void>()
    let deleteReview = PublishSubject<Int>()
  }
  
  struct Output {
    let showLoading = PublishRelay<Bool>()
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  init(userDefaults: UserDefaultsUtil) {
    self.userDefaults = userDefaults
    super.init()
    
    self.input.tapShare
      .withLatestFrom(self.store)
      .bind(onNext: self.shareToKakao(store:))
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
  
  private func shareToKakao(store: Store?) {
    guard let store = store else { return }
    let urlString = "https://map.kakao.com/link/map/\(store.storeName),\(store.latitude),\(store.longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let webURL = URL(string: urlString)
    let link = Link(
      webUrl: webURL,
      mobileWebUrl: webURL,
      androidExecutionParams: ["storeId": String(store.id)],
      iosExecutionParams: ["storeId": String(store.id)]
    )
    let content = Content(
      title: "올 때 붕어빵, 잊지마!!!",
      imageUrl: URL(string: HTTPUtils.url + "/images/share-with-kakao.png")!,
      imageWidth: 500,
      imageHeight: 500,
      description: "당신은 붕어빵 셔틀에 당첨되셨습니다.\n지금 바로 가슴속 3천원을 설치하고 위치를 파악하여 미션을 수행하세요!",
      link: link
    )
    let feedTemplate = FeedTemplate(
      content: content,
      social: nil,
      buttonTitle: nil,
      buttons: [Button(title: "놀러가기", link: link)]
    )
    
    LinkApi.shared.defaultLink(templatable: feedTemplate) { (linkResult, error) in
      if let error = error {
        let alertContent = AlertContent(title: "Error in Kakao link", message: error.localizedDescription)
        
        self.output.showSystemAlert.accept(alertContent)
      } else {
        if let linkResult = linkResult {
          UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
        }
      }
    }
  }
  
  private func deleteReview(reviewId: Int) {
    self.output.showLoading.accept(true)
    ReviewService().deleteRevie(reviewId: reviewId)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          if var updatedStore = try? self.store.value() {
            for reviewIndex in updatedStore.reviews.indices {
              if updatedStore.reviews[reviewIndex].id == reviewId {
                updatedStore.reviews.remove(at: reviewIndex)
                break
              }
            }
            self.store.onNext(updatedStore)
          }
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          }
          self.output.showLoading.accept(false)
        }
      ).disposed(by: self.disposeBag)
  }
}
