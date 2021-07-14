import RxSwift
import RxCocoa

class SplashViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let userDefaults: UserDefaultsUtil
  let userService: UserServiceProtocol
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let goToSignIn = PublishRelay<Void>()
    let goToMain = PublishRelay<Void>()
    let goToSignInWithAlert = PublishRelay<AlertContent>()
    let showMaintenanceAlert = PublishRelay<AlertContent>()
  }
  
  
  init(userDefaults: UserDefaultsUtil, userService: UserServiceProtocol) {
    self.userDefaults = userDefaults
    self.userService = userService
    super.init()
    
    self.input.viewDidLoad
      .bind(onNext: self.validateToken)
      .disposed(by: self.disposeBag)
  }
  
  private func validateToken() {
    let token = self.userDefaults.getUserToken()
    
    if self.validateTokenFromLocal(token: token) {
      self.validateTokenFromServer(token: token)
    } else {
      self.output.goToSignIn.accept(())
    }
  }
  
  private func validateTokenFromLocal(token: String) -> Bool {
    return !token.isEmpty
  }
  
  private func validateTokenFromServer(token: String) {
    self.userService.validateToken(token: token)
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
