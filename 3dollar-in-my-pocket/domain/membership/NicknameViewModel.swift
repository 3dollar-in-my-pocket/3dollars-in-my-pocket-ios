import RxSwift
import RxCocoa

class NicknameViewModel: BaseViewModel {
  struct Input {
    let nickname = PublishSubject<String>()
    let tapStartButton = PublishSubject<Void>()
  }
  
  struct Output {
    let startButtonEnable = PublishRelay<Bool>()
    let presentPolicy = PublishRelay<Void>()
    let errorLabelHidden = PublishRelay<Bool>()
  }
  
  let input = Input()
  let output = Output()
  let signinRequest: SigninRequest
  var userDefaults: UserDefaultsUtil
  let userService: UserServiceProtocol
    private let deviceService: DeviceServiceProtocol
    var isSignupSuccess = false
  
  
  init(
    signinRequest: SigninRequest,
    userDefaults: UserDefaultsUtil,
    userService: UserServiceProtocol,
    deviceService: DeviceServiceProtocol
  ) {
    self.signinRequest = signinRequest
    self.userDefaults = userDefaults
    self.userService = userService
      self.deviceService = deviceService
    super.init()
    
    self.input.nickname
      .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
      .bind(to: self.output.startButtonEnable)
      .disposed(by: self.disposeBag)
    
    self.input.tapStartButton
      .withLatestFrom(self.input.nickname)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .nickname_change_button_clicked, page: .nickname_initialize_page)
      })
      .bind(onNext: self.setNickname(nickname:))
      .disposed(by: disposeBag)
  }
  
    private func setNickname(nickname: String) {
        let signupRequest = SignupRequest(
            name: nickname,
            socialType: self.signinRequest.socialType,
            token: self.signinRequest.token
        )
        if self.isSignupSuccess {
            self.output.presentPolicy.accept(())
        } else {
            self.showLoading.accept(true)
            self.userService.signup(request: signupRequest)
                .subscribe(
                    onNext: { [weak self] response in
                        guard let self = self else { return }
                        self.userDefaults.userId = response.userId
                        self.userDefaults.authToken = response.token
                        self.isSignupSuccess = true

                        self.deviceService.getFCMToken()
                            .flatMap { pushToken -> Observable<String> in
                                return self.deviceService.registerDevice(
                                    pushPlatformType: .fcm,
                                    pushToken: pushToken
                                )
                            }
                            .subscribe { _ in
                                self.showLoading.accept(false)
                                self.output.presentPolicy.accept(())
                            }
                            .disposed(by: self.disposeBag)
                    },
                    onError: self.handleSignupError(error:)
                )
                .disposed(by: self.disposeBag)
        }
    }
  
  private func handleSignupError(error: Error) {
    self.showLoading.accept(false)
    if let signupError = error as? SignupError {
      switch signupError {
      case .alreadyExistedNickname:
        self.output.errorLabelHidden.accept(false)
        GA.shared.logEvent(event: .nickname_already_existed, page: .nickname_initialize_page)
      case .badRequest:
        let alertContent = AlertContent(
          title: nil,
          message: signupError.errorDescription
        )
        
        self.showSystemAlert.accept(alertContent)
        self.showLoading.accept(false)
      }
    } else {
      self.showErrorAlert.accept(error)
      self.showLoading.accept(false)
    }
  }
}
