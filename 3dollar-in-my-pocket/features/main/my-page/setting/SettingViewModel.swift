import RxSwift
import RxCocoa

class SettingViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    
  }
  
  struct Output {
    let user = BehaviorRelay<User>(value: User(nickname: "", socialId: "", socialType: "KAKAO"))
    let showLoading = PublishRelay<Bool>()
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  let userDefaults: UserDefaultsUtil
  let userService: UserServiceProtocol
  
  init(
    userDefaults: UserDefaultsUtil,
    userService: UserServiceProtocol
  ) {
    self.userDefaults = userDefaults
    self.userService = userService
    super.init()
  }
  
  func fetchMyInfo() {
    self.output.showLoading.accept(true)
    self.userService.getUserInfo(userId: self.userDefaults.getUserId())
      .subscribe { user in
        self.output.user.accept(user)
        self.output.showLoading.accept(false)
      } onError: { error in
        if let error = error as? CommonError {
          let alertContent = AlertContent(title: "Error in fetchMyInfo", message: error.description)
          
          self.output.showSystemAlert.accept(alertContent)
          self.output.showLoading.accept(false)
        }
      }
      .disposed(by: disposeBag)
  }
}
