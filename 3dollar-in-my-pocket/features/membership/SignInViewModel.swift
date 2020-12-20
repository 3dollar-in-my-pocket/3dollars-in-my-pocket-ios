import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser

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
    if (AuthApi.isKakaoTalkLoginAvailable()) {
      AuthApi.shared.loginWithKakaoTalk {(oauthToken, error) in
        if let error = error {
          if (error as NSError).code != 2 {
            let alertContent = AlertContent(
              title: "Error in Kakao",
              message: error.localizedDescription
            )
            
            self.output.showSystemAlert.accept(alertContent)
          }
        } else {
          self.requestKakaoInfo()
        }
      }
    } else {
      AuthApi.shared.loginWithKakaoAccount {(oauthToken, error) in
        if let error = error {
          if (error as NSError).code != 2 {
            let alertContent = AlertContent(
              title: "Error in Kakao",
              message: error.localizedDescription
            )
            
            self.output.showSystemAlert.accept(alertContent)
          }
        }
        else {
          self.requestKakaoInfo()
        }
      }
    }
  }
  
  private func requestKakaoInfo() {
    UserApi.shared.me { (user, error) in
      if let error = error {
        let alertContent = AlertContent(
          title: "Error in requestKakaoInfo",
          message: error.localizedDescription
        )
        
        self.output.showSystemAlert.accept(alertContent)
      }
      else {
        if let userId = user?.id {
          self.signIn(socialId: String(userId), socialType: "KAKAO")
        }
      }
    }
  }
  
  private func signIn(socialId: String, socialType: String) {
    let user = User.init(socialId: socialId, socialType: socialType)
    
    self.userService.signIn(user: user)
      .subscribe { [weak self] signIn in
        guard let self = self else { return }
        if signIn.state {
          self.userDefaults.setUserToken(token: signIn.token)
          self.userDefaults.setUserId(id: signIn.id)
          self.output.goToMain.accept(())
        } else {
          self.output.goToNickname.accept((signIn.id, signIn.token))
        }
      } onError: { [weak self] error in
        if let httpError = error as? HTTPError {
          self?.httpErrorAlert.accept(httpError)
        }
      }
      .disposed(by: disposeBag)
  }
}
