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
    
  }
  
  override init() {
    super.init()
    
    self.input.tapShare
      .subscribe(onNext: self.shareToKakao)
      .disposed(by: disposeBag)
  }
  
  private func shareToKakao() {
    let link = Link(webUrl: nil, mobileWebUrl: nil, androidExecutionParams: nil, iosExecutionParams: nil)
    let content = Content(
      title: "올 때 붕어빵, 잊지마!!!",
      imageUrl: URL(string: "https://post-phinf.pstatic.net/MjAxODEyMThfMTcw/MDAxNTQ1MDk4MzEyNDE2.6oqFEX_wTnqKtayMLHzahEjc9w7VknlzKZSlvdxsd68g.1XvdtkY9zlUyahaCevfjBUG0Oh7LWHVDRB1Jknah0ecg.PNG/08.png?type=w1200")!,
      imageWidth: 800,
      imageHeight: 800,
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
        print(error)
      } else {
        print("defaultLink() success.")
        
        if let linkResult = linkResult {
          UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
        }
      }
    }
  }
}
