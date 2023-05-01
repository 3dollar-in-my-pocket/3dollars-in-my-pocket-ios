import ReactorKit

import RxSwift
import RxCocoa

final class BookmarkSigninDialogReactor: BaseReactor, Reactor {
    enum Action {
        case tapKakaoButton
        case tapAppleButton
    }
    
    enum Mutation {
        case goToMain
        case pushNickname(SigninRequest)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    struct State {
        @Pulse var goToMain: Void?
        @Pulse var pushNickname: SigninRequest?
        @Pulse var showErrorAlert: Error?
        @Pulse var showLoading: Bool?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let deviceService: DeviceServiceProtocol
    private var userDefaults: UserDefaultsUtil
    private let kakaoManager: SigninManagerProtocol
    private let appleManager: SigninManagerProtocol
    
    init(
        userDefaults: UserDefaultsUtil,
        userService: UserServiceProtocol,
        deviceService: DeviceServiceProtocol,
        kakaoManager: SigninManagerProtocol,
        appleManager: SigninManagerProtocol,
        state: State = State()
    ) {
        self.userDefaults = userDefaults
        self.userService = userService
        self.deviceService = deviceService
        self.kakaoManager = kakaoManager
        self.appleManager = appleManager
        self.initialState = state
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoButton:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.signinWithKakao(),
                .just(.showLoading(isShow: false))
            ])
            
        case .tapAppleButton:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.signinWithApple(),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .goToMain:
            newState.goToMain = ()
            
        case .pushNickname(let signinRequest):
            newState.pushNickname = signinRequest
            
        case .showErrorAlert(let error):
            newState.showErrorAlert = error
            
        case .showLoading(let isShow):
            newState.showLoading = isShow
        }
        
        return newState
    }
    
    private func signinWithKakao() -> Observable<Mutation> {
        self.kakaoManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.signin(request: signinRequest)
            }
            .catch { error in
                if case .custom(let message) = error as? BaseError,
                   message == "cancel" {
                    return .just(.showLoading(isShow: false))
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
    
    private func signinWithApple() -> Observable<Mutation> {
        return self.appleManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.signin(request: signinRequest)
            }
            .catch { error in
                if case .custom(let message) = error as? BaseError,
                   message == "cancel" {
                    return .just(.showLoading(isShow: false))
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
  
    private func signin(request: SigninRequest) -> Observable<Mutation> {
        return self.userService.signin(request: request)
            .do(onNext: { [weak self] signinResponse in
                self?.userDefaults.userId = signinResponse.userId
                self?.userDefaults.authToken = signinResponse.token
            })
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.deviceService.getFCMToken()
                    .flatMap { pushToken -> Observable<String> in
                        return self.deviceService.refreshDeivce(
                            pushPlatformType: .fcm,
                            pushToken: pushToken
                        )
                    }
                    .map { _ in .goToMain }
            }
            .catch { error in
                if let httpError = error as? HTTPError,
                   httpError == .notFound {
                    return .just(.pushNickname(request))
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
}
