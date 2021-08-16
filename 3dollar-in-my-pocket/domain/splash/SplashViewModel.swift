import RxSwift
import RxCocoa
import FirebaseRemoteConfig

class SplashViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let userDefaults: UserDefaultsUtil
  let userService: UserServiceProtocol
  let remoteConfigService: RemoteConfigProtocol
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let goToSignIn = PublishRelay<Void>()
    let goToMain = PublishRelay<Void>()
    let goToSignInWithAlert = PublishRelay<AlertContent>()
    let showMaintenanceAlert = PublishRelay<AlertContent>()
    let showUpdateAlert = PublishRelay<Void>()
  }
  
  
  init(
    userDefaults: UserDefaultsUtil,
    userService: UserServiceProtocol,
    remoteConfigService: RemoteConfigProtocol
  ) {
    self.userDefaults = userDefaults
    self.userService = userService
    self.remoteConfigService = remoteConfigService
    super.init()
    
    self.input.viewDidLoad
      .bind(onNext: self.checkMinimalVersion)
      .disposed(by: self.disposeBag)
  }
  
  private func checkMinimalVersion() {
    self.remoteConfigService.fetchMinimalVersion()
      .subscribe(onNext: { [weak self] minimalVersion in
        if VersionUtils.isNeedUpdate(
            currentVersion: VersionUtils.appVersion,
            minimumVersion: minimalVersion
        ) {
          self?.output.showUpdateAlert.accept(())
        } else {
          self?.validateToken()
        }
      },
      onError: self.showErrorAlert.accept(_:))
      .disposed(by: self.disposeBag)
  }
  
  private func validateToken() {
    let token = self.userDefaults.getUserToken()
    
    if self.validateTokenFromLocal(token: token) {
      self.validateTokenFromServer()
    } else {
      self.output.goToSignIn.accept(())
    }
  }
  
  private func validateTokenFromLocal(token: String) -> Bool {
    return !token.isEmpty
  }
  
  private func validateTokenFromServer() {
    self.userService.fetchUserInfo()
      .map { _ in Void() }
      .subscribe(
        onNext: self.output.goToMain.accept(_:),
        onError: self.handelValidationError(error:)
      )
      .disposed(by: disposeBag)
  }
  
  private func handelValidationError(error: Error) {
    if let httpError = error as? HTTPError {
      switch httpError {
      case .forbidden, .unauthorized:
        let alertContent = AlertContent(title: nil, message: httpError.description)
        
        self.output.goToSignInWithAlert.accept(alertContent)
      case .maintenance:
        let alertContent = AlertContent(title: nil, message: httpError.description)
        
        self.output.showMaintenanceAlert.accept(alertContent)
      default:
        self.showErrorAlert.accept(error)
      }
    } else {
      self.showErrorAlert.accept(error)
    }
  }
}
