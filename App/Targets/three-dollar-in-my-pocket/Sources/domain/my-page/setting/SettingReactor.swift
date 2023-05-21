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
        case logout
        case signout
    }
    
    enum Mutation {
        case setUser(User)
        case updateNickname(String)
        case setPushEnable(Bool)
        case pushEditNickname(String)
        case goToSignin
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
    private let kakaoSigninManager: SigninManagerProtocol
    private let appleSigninManager: SigninManagerProtocol
    private let globalState: GlobalState
  
    init(
        userDefaults: UserDefaultsUtil,
        userService: UserServiceProtocol,
        deviceService: DeviceServiceProtocol,
        analyticsManager: AnalyticsManagerProtocol,
        kakaoSigninManager: SigninManagerProtocol,
        appleSigninManager: SigninManagerProtocol,
        globalState: GlobalState,
        state: State = State(user: User())
    ) {
        self.userDefaults = userDefaults
        self.userService = userService
        self.deviceService = deviceService
        self.analyticsManager = analyticsManager
        self.kakaoSigninManager = kakaoSigninManager
        self.appleSigninManager = appleSigninManager
        self.globalState = globalState
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
            
        case .logout:
            let socialType = self.currentState.user.socialType
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.logout(socialType: socialType),
                .just(.showLoading(isShow: false))
            ])
            
        case .signout:
            let socialType = self.currentState.user.socialType
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.signout(socialType: socialType),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge([
            mutation,
            self.globalState.updateNickname
                .map { .updateNickname($0) }
        ])
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setUser(let user):
            newState.user = user
            
        case .updateNickname(let nickname):
            newState.user.name = nickname
            
        case .setPushEnable(let isEnable):
            newState.user.pushInfo.isPushEnable = isEnable
            
        case .pushEditNickname(let nickname):
            newState.pushEditNickname = nickname
            
        case .goToSignin:
            newState.goToSignin = ()
            
        case .showLoading(let isShow):
            newState.showLoading = isShow
            
        case .showErrorAlert(let error):
            newState.showErrorAlert = error
        }
        
        return newState
    }
    
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
                    pushToken: pushToken
                )
                .do(onNext: { [weak self] _ in
                    self?.analyticsManager.setPushEnable(isEnable: true)
                })
            }
            .map { _ in .setPushEnable(true) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func setDisablePush() -> Observable<Mutation> {
        return self.deviceService.deleteDevice()
            .do(onNext: { [weak self] _ in
                self?.analyticsManager.setPushEnable(isEnable: false)
            })
            .map { .setPushEnable(false) }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func logout(socialType: SocialType) -> Observable<Mutation> {
        switch socialType {
        case .kakao:
            return self.kakaoSigninManager.logout()
                .do(onNext: { [weak self] _ in
                    self?.userDefaults.clear()
                })
                .map { .goToSignin }
                .catch { .just(.showErrorAlert($0)) }
            
        case .apple:
            return self.appleSigninManager.logout()
                .do(onNext: { [weak self] _ in
                    self?.userDefaults.clear()
                })
                .map { .goToSignin }
                .catch { .just(.showErrorAlert($0)) }
            
        default:
            return .empty()
        }
    }
    
    private func signout(socialType: SocialType) -> Observable<Mutation> {
        switch socialType {
        case .kakao:
            return self.kakaoSigninManager.signout()
                .flatMap { [weak self] _ -> Observable<Void> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    return self.signout()
                }
                .map { .goToSignin }
                .catch { .just(.showErrorAlert($0)) }
                
            
        case .apple:
            return self.appleSigninManager.signout()
                .flatMap { [weak self] _ -> Observable<Void> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    return self.signout()
                }
                .map { .goToSignin }
                .catch { .just(.showErrorAlert($0)) }
            
        default:
            return .empty()
        }
    }
  
    private func signout() -> Observable<Void> {
        return self.userService.signout()
            .do(onNext: {
                self.userDefaults.clear()
            })
    }
}
