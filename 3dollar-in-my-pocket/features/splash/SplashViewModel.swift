import RxSwift
import RxCocoa

class SplashViewModel: BaseViewModel {
  
  let output = Output()
  let userDefaults: UserDefaultsUtil
  
  struct Output {
    let goToSignIn = PublishRelay<Void>()
    let goToMain = PublishRelay<Void>()
  }
  
  
  init(userDefaults: UserDefaultsUtil) {
    self.userDefaults = userDefaults
    super.init()
  }
  
  func validateUserToken() {
    if !self.userDefaults.getUserToken().isEmpty {
      self.output.goToMain.accept(())
    } else {
      self.output.goToSignIn.accept(())
    }
  }
}
