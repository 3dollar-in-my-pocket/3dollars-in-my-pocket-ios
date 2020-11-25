import RxSwift
import RxCocoa
import KakaoOpenSDK

class SignInViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let userService: UserServiceProtocol
  let userDefaults: UserDefaultsUtil
  
  struct Input {
    let tapKakao = PublishSubject<Void>()
    let signWithApple = PublishSubject<String>()
  }
  
  struct Output {
    let goToMain = PublishRelay<Void>()
    let goToNickname = PublishRelay<(Int, String)>()
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  
  init(
    userDefaults: UserDefaultsUtil,
    userService: UserServiceProtocol
  ) {
    self.userDefaults = userDefaults
    self.userService = userService
    super.init()
    
    self.input.tapKakao
      .bind(onNext: self.requestKakaoSignIn)
      .disposed(by: disposeBag)
    
    self.input.signWithApple
      .map { ($0, "APPLE")}
      .bind(onNext: self.signIn)
      .disposed(by: disposeBag)
  }
  
  private func requestKakaoSignIn() {
    guard let kakaoSession = KOSession.shared() else {
      let alertContent = AlertContent(
        title: "Error in Kakao",
        message: "Kakao session is null"
      )
      
      self.output.showSystemAlert.accept(alertContent)
      return
    }
    
    if kakaoSession.isOpen() {
      kakaoSession.close()
    }
    
    kakaoSession.open { [weak self] (error) in
      guard let self = self else { return }
      if let error = error {
        if (error as NSError).code != 2 {
          let alertContent = AlertContent(
            title: "Error in Kakao",
            message: error.localizedDescription
          )
          
          self.output.showSystemAlert.accept(alertContent)
        }
      } else {
        KOSessionTask.userMeTask { (error, me) in
          if let userId = me?.id {
            self.signIn(socialId: userId, socialType: "KAKAO")
          }
        }
      }
    }
  }
  
  private func signIn(socialId: String, socialType: String) {
    let user = User.init(socialId: socialId, socialType: socialType)
    
    self.userService.signIn(user: user)
      .subscribe { signIn in
        if signIn.state {
          self.userDefaults.setUserToken(token: signIn.token)
          self.userDefaults.setUserId(id: signIn.id)
          self.output.goToMain.accept(())
        } else {
          self.output.goToNickname.accept((signIn.id, signIn.token))
        }
      } onError: { error in
        let alertContent = AlertContent(
          title: "Error in sign-in",
          message: error.localizedDescription
        )
        
        self.output.showSystemAlert.accept(alertContent)
      }
      .disposed(by: disposeBag)
  }
}
