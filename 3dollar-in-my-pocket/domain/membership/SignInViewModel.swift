import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser

class SignInViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let userService: UserServiceProtocol
  let userDefaults: UserDefaultsUtil
  let kakaoManager: SigninManagerProtocol
  let appleManager: SigninManagerProtocol
  
  struct Input {
    let tapKakaoButton = PublishSubject<Void>()
    let tapAppleButton = PublishSubject<Void>()
  }
  
  struct Output {
    let goToMain = PublishRelay<Void>()
    let goToNickname = PublishRelay<SigninRequest>()
  }
  
  
  init(
    userDefaults: UserDefaultsUtil,
    userService: UserServiceProtocol,
    kakaoManager: SigninManagerProtocol,
    appleManager: SigninManagerProtocol
  ) {
    self.userDefaults = userDefaults
    self.userService = userService
    self.kakaoManager = kakaoManager
    self.appleManager = appleManager
    super.init()
    
    self.input.tapKakaoButton
      .do(onNext: { _ in
        GA.shared.logEvent(event: .kakao_login_button_clicked, page: .login_page)
      })
      .flatMap(self.kakaoManager.signin)
      .subscribe(
        onNext: self.signin(request:),
        onError: self.showErrorAlert.accept(_:)
      )
      .disposed(by: self.disposeBag)
    
    self.input.tapAppleButton
      .do(onNext: { _ in
        GA.shared.logEvent(event: .apple_login_button_clicked, page: .login_page)
      })
      .flatMap(self.appleManager.signin)
      .subscribe(
        onNext: self.signin(request:),
        onError: self.showErrorAlert.accept(_:)
      )
      .disposed(by: self.disposeBag)
  }
  
  private func signin(request: SigninRequest) {
    self.userService.signin(request: request)
      .subscribe { [weak self] response in
        guard let self = self else { return }
        
        self.userDefaults.setUserToken(token: response.token)
        self.output.goToMain.accept(())
      } onError: { [weak self] error in
        guard let self = self else { return }
        
        if let httpError = error as? HTTPError,
           httpError == .notFound {
          self.output.goToNickname.accept(request)
        } else {
          self.showErrorAlert.accept(error)
        }
      }
      .disposed(by: disposeBag)
  }
}
