import RxSwift
import RxCocoa

class SplashViewModel: BaseViewModel {
  
  let output = Output()
  let userDefaults: UserDefaultsUtil
  let userService: UserServiceProtocol
  
  struct Output {
    let goToSignIn = PublishRelay<Void>()
    let goToMain = PublishRelay<Void>()
    let showGoToSignInAlert = PublishRelay<AlertContent>()
    let showMaintenanceAlert = PublishRelay<AlertContent>()
  }
  
  
  init(userDefaults: UserDefaultsUtil, userService: UserServiceProtocol) {
    self.userDefaults = userDefaults
    self.userService = userService
    super.init()
  }
  
  func validateUserToken() {
    let token = self.userDefaults.getUserToken()
    if !token.isEmpty {
      self.validateTokenFromServer(token: token)
    } else {
      self.output.goToSignIn.accept(())
    }
  }
  
  private func validateTokenFromServer(token: String) {
    self.userService.validateToken(token: token)
      .subscribe(
        onNext: { [weak self] message in
          guard let self = self else { return }
          self.output.goToMain.accept(())
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            switch httpError {
            case .forbidden, .unauthorized:
              let alertContent = AlertContent(title: nil, message: httpError.description)
              
              self.output.showGoToSignInAlert.accept(alertContent)
            case .maintenance:
              let alertContent = AlertContent(title: nil, message: httpError.description)
              
              self.output.showMaintenanceAlert.accept(alertContent)
            }
          }
        }
      )
      .disposed(by: disposeBag)
  }
}
