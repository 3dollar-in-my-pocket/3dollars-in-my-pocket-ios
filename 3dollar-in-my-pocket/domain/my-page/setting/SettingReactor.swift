import ReactorKit
import RxSwift
import RxCocoa
import KakaoSDKUser
import KakaoSDKCommon

final class SettingReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case togglePushEnable(Bool)
        case tapEditNickname
        case signout
        case withdrawal
    }
    
    enum Mutation {
        case setUser(User)
        case setPushEnable(Bool)
        case pushEditNickname(String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var user: User
        @Pulse var pushEditNickname: String?
        @Pulse var goToSignin: Void?
        @Pulse var showLoading: Bool?
        @Pulse var showErrorAlert: Error?
    }
    
    let initialState: State
    private let userDefaults: UserDefaultsUtil
    private let userService: UserServiceProtocol
    private let deviceService: DeviceServiceProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    
//  struct Input {
//    let signOut = PublishSubject<Void>()
//    let tapRename = PublishSubject<Void>()
//    let withdrawal = PublishSubject<Void>()
//  }
//
//  struct Output {
//    let user = BehaviorRelay<User>(value: User())
//    let goToRename = PublishRelay<String>()
//    let goToSignIn = PublishRelay<Void>()
//    let showLoading = PublishRelay<Bool>()
//  }
  
    init(
        userDefaults: UserDefaultsUtil,
        userService: UserServiceProtocol,
        deviceService: DeviceServiceProtocol,
        analyticsManager: AnalyticsManagerProtocol,
        state: State = State(user: User())
    ) {
        self.userDefaults = userDefaults
        self.userService = userService
        self.deviceService = deviceService
        self.analyticsManager = analyticsManager
        self.initialState = state
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.fetchMyInfo(),
                .just(.showLoading(isShow: false))
            ])
            
        case .togglePushEnable(let isOn):
            if isOn {
                return self.setEnablePush()
            } else {
                return self.setDisablePush()
            }
            
        case .tapEditNickname:
            let nickname = self.currentState.user.name
            
            return .just(.pushEditNickname(nickname))
            
        case .signout:
        case .withdrawal:
        }
    }
//        self.input.signOut
//            .withLatestFrom(self.output.user)
//            .do(onNext: { _ in
//                GA.shared.logEvent(event: .logout_button_clicked, page: .setting_page)
//            })
//                .bind(onNext: self.signOut(user:))
//                .disposed(by: disposeBag)
//
//                self.input.tapRename
//                .withLatestFrom(self.output.user) { $1.name }
//                .do(onNext: { _ in
//                    GA.shared.logEvent(event: .nickname_change_page_button_clicked, page: .setting_page)
//                })
//                    .bind(to: self.output.goToRename)
//                    .disposed(by: disposeBag)
//
//                    self.input.withdrawal
//                    .withLatestFrom(self.output.user)
//                    .do(onNext: { _ in
//                        GA.shared.logEvent(event: .signout_button_clicked, page: .setting_page)
//                    })
//                        .bind(onNext: self.withdrawal(user:))
//                        .disposed(by: disposeBag)
//                        }
    
    private func fetchMyInfo() -> Observable<Mutation> {
        return self.userService.fetchUser()
            .map { .setUser($0) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func setEnablePush() -> Observable<Mutation> {
        return self.deviceService.getFCMToken()
            .flatMap { [weak self] pushToken -> Observable<String> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.deviceService.registerDevice(
                    pushPlatformType: .fcm,
                    pushSettings: [.advertisement],
                    pushToken: pushToken
                )
                .do(onNext: { _ in
                    self.analyticsManager.setPushEnable(isEnable: true)
                })
            }
            .map { _ in .setPushEnable(true) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func setDisablePush() -> Observable<Mutation> {
        return self.deviceService.deleteDevice()
            .map { .setPushEnable(false) }
            .catch { .just(.showErrorAlert($0)) }
    }
  
    private func signOut(user: User) {
        switch user.socialType {
        case .kakao:
            self.signOutKakao()
        case .apple:
            self.signOutApple()
        default:
            break
        }
    }
  
  private func withdrawal(user: User) {
    switch user.socialType {
    case .kakao:
      self.unlinkKakao()
    case .apple:
      self.withdrawal()
    default:
      break
    }
  }
  
  private func withdrawal() {
    self.output.showLoading.accept(true)
    self.userService.withdrawal()
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
