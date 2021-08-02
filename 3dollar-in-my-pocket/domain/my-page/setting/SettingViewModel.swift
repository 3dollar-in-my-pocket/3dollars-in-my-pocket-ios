import RxSwift
import RxCocoa
import KakaoSDKUser
import KakaoSDKCommon


class SettingViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    let signOut = PublishSubject<Void>()
    let tapRename = PublishSubject<Void>()
    let withdrawal = PublishSubject<Void>()
  }
  
  struct Output {
    let user = BehaviorRelay<User>(value: User())
    let goToRename = PublishRelay<String>()
    let goToSignIn = PublishRelay<Void>()
    let showLoading = PublishRelay<Bool>()
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
      .do(onNext: { _ in
        GA.shared.logEvent(event: .logout_button_clicked, page: .setting_page)
      })
      .bind(onNext: self.signOut(user:))
      .disposed(by: disposeBag)
    
    self.input.tapRename
      .withLatestFrom(self.output.user) { $1.name }
      .do(onNext: { _ in
        GA.shared.logEvent(event: .nickname_change_page_button_clicked, page: .setting_page)
      })
      .bind(to: self.output.goToRename)
      .disposed(by: disposeBag)
    
    self.input.withdrawal
      .withLatestFrom(self.output.user)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .signout_button_clicked, page: .setting_page)
      })
      .bind(onNext: self.withdrawal(user:))
      .disposed(by: disposeBag)
  }
  
  func fetchMyInfo() {
    self.output.showLoading.accept(true)
    self.userService.getUserInfo(userId: self.userDefaults.getUserId())
      .subscribe { [weak self] user in
        guard let self = self else { return }
        self.output.user.accept(user)
        self.output.showLoading.accept(false)
      } onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        } else if let error = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: error.description)
          
          self.showSystemAlert.accept(alertContent)
        }
        self.output.showLoading.accept(false)
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
      } onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        } else if let error = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: error.description)
          
          self.showSystemAlert.accept(alertContent)
        }
        self.output.showLoading.accept(false)
      }
      .disposed(by: disposeBag)
  }
  
  private func signOutKakao() {
    UserApi.shared.logout { error in
      if let kakaoError = error as? SdkError,
         kakaoError.getApiError().reason == .InvalidAccessToken {
        // KAKAO 토큰이 사라진 경우: 개발서버앱으로 왔다갔다 하는경우?
        self.userDefaults.clear()
        self.output.goToSignIn.accept(())
      } else {
        if let error = error {
          let alertContent = AlertContent(
            title: "Error in signOutKakao",
            message: error.localizedDescription
          )
          
          self.showSystemAlert.accept(alertContent)
        }
        else {
          self.userDefaults.clear()
          self.output.goToSignIn.accept(())
        }
      }
    }
  }
  
  private func signOutApple() {
    self.userDefaults.clear()
    self.output.goToSignIn.accept(())
  }
  
  private func unlinkKakao() {
    UserApi.shared.unlink { error in
      if let kakaoError = error as? SdkError,
         kakaoError.getApiError().reason == .InvalidAccessToken {
        // KAKAO 토큰이 사라진 경우: 개발서버앱으로 왔다갔다 하는경우?
        self.withdrawal()
      } else {
        if let error = error {
          let alertContent = AlertContent(
            title: "Error in unlinkKakao",
            message: error.localizedDescription
          )
          
          self.showSystemAlert.accept(alertContent)
        } else {
          self.withdrawal()
        }
      }
    }
  }
}
