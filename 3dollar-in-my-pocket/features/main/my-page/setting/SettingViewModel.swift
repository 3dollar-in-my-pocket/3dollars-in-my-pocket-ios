import RxSwift
import RxCocoa
import KakaoSDKUser


class SettingViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    let signOut = PublishSubject<Void>()
    let tapRename = PublishSubject<Void>()
    let withdrawal = PublishSubject<Void>()
  }
  
  struct Output {
    let user = BehaviorRelay<User>(value: User(nickname: "", socialId: "", socialType: "APPLE"))
    let goToRename = PublishRelay<String>()
    let goToSignIn = PublishRelay<Void>()
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
    
    self.input.signOut
      .withLatestFrom(self.output.user)
      .bind(onNext: self.signOut(user:))
      .disposed(by: disposeBag)
    
    self.input.tapRename
      .withLatestFrom(self.output.user) { $1.nickname! }
      .bind(to: self.output.goToRename)
      .disposed(by: disposeBag)
    
    self.input.withdrawal
      .withLatestFrom(self.output.user)
      .bind(onNext: self.withdrawal(user:))
      .disposed(by: disposeBag)
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
  
  private func signOut(user: User) {
    switch user.socialType {
    case .KAKAO:
      self.signOutKakao()
    case .APPLE:
      self.signOutApple()
    default:
      break
    }
  }
  
  private func withdrawal(user: User) {
    switch user.socialType {
    case .KAKAO:
      self.unlinkKakao()
    case .APPLE:
      self.withdrawal()
    default:
      break
    }
  }
  
  private func withdrawal() {
    self.output.showLoading.accept(true)
    self.userService.withdrawal(userId: self.userDefaults.getUserId())
      .subscribe { [weak self] _ in
        guard let self = self else { return }
        self.userDefaults.clear()
        self.output.goToSignIn.accept(())
        self.output.showLoading.accept(false)
      } onError: { error in
        if let error = error as? CommonError {
          let alertContent = AlertContent(
            title: "Error in withdrawal",
            message: error.description
          )
          
          self.output.showLoading.accept(false)
          self.output.showSystemAlert.accept(alertContent)
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func signOutKakao() {
    UserApi.shared.logout { error in
      if let error = error {
        let alertContent = AlertContent(
          title: "Error in signOutKakao",
          message: error.localizedDescription
        )
        
        self.output.showSystemAlert.accept(alertContent)
      }
      else {
        self.userDefaults.clear()
        self.output.goToSignIn.accept(())
      }
    }
  }
  
  private func signOutApple() {
    self.userDefaults.clear()
    self.output.goToSignIn.accept(())
  }
  
  private func unlinkKakao() {
    UserApi.shared.unlink { error in
      if let error = error {
        let alertContent = AlertContent(
          title: "Error in unlinkKakao",
          message: error.localizedDescription
        )
        
        self.output.showSystemAlert.accept(alertContent)
      } else {
        self.withdrawal()
      }
    }
  }
}
