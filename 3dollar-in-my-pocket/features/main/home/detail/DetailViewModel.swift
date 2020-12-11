import RxSwift
import RxCocoa
import KakaoSDKLink
import KakaoSDKTemplate

class DetailViewModel: BaseViewModel {
  
  var store = BehaviorSubject<Store?>.init(value: nil)
  var location: (latitude: Double, longitude: Double) = (0 , 0)
  let input = Input()
  let output = Output()
  
  struct Input {
    let tapShare = PublishSubject<Void>()
  }
  
  struct Output {
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  override init() {
    super.init()
    
    self.input.tapShare
      .subscribe(onNext: self.shareToKakao)
      .disposed(by: disposeBag)
  }
  
  private func shareToKakao() {
    let link = Link(
      webUrl: nil,
      mobileWebUrl: nil,
      androidExecutionParams: nil,
      iosExecutionParams: nil
    )
    let content = Content(
      title: "올 때 붕어빵, 잊지마!!!",
      imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/dollar-in-my-pocket.appspot.com/o/kakao_link.png?alt=media&token=c3dd508f-63c6-4645-bff6-808c5a902417")!,
      imageWidth: 500,
      imageHeight: 500,
      description: "000님께서 [가슴속 3천원]의 가게 정보를 공유하셨습니다. 지금 바로 [가슴속 3천원] 앱을 설치하시고 더 많은 길거리 음식 맛집을 알아보세요!",
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
}
