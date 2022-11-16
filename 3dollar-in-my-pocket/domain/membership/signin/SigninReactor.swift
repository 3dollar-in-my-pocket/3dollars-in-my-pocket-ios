import ReactorKit
import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser

final class SigninReactor: BaseReactor, Reactor {
    enum Action {
        case tapKakaoButton
        case tapAppleButton
        case tapWithoutSignin
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
    let userService: UserServiceProtocol
    var userDefaults: UserDefaultsUtil
    let kakaoManager: SigninManagerProtocol
    let appleManager: SigninManagerProtocol
    
    init(
        userDefaults: UserDefaultsUtil,
        userService: UserServiceProtocol,
        kakaoManager: SigninManagerProtocol,
        appleManager: SigninManagerProtocol,
        state: State = State()
    ) {
        self.userDefaults = userDefaults
        self.userService = userService
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
            
        case .tapWithoutSignin:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.signinAnonymous(),
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
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func signinWithApple() -> Observable<Mutation> {
        return self.appleManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.signin(request: signinRequest)
            }
            .catch { .just(.showErrorAlert($0)) }
    }
  
    private func signin(request: SigninRequest) -> Observable<Mutation> {
        return self.userService.signin(request: request)
            .do(onNext: { [weak self] signinResponse in
                self?.userDefaults.userId = signinResponse.userId
                self?.userDefaults.authToken = signinResponse.token
            })
            .map { _ in .goToMain }
            .catch { error in
                if let httpError = error as? HTTPError,
                   httpError == .notFound {
                    return .just(.pushNickname(request))
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
    
    private func signinAnonymous() -> Observable<Mutation> {
        return self.userService.signinAnonymous()
            .do(onNext: { [weak self] signinResponse in
                self?.userDefaults.userId = signinResponse.userId
                self?.userDefaults.authToken = signinResponse.token
            })
            .map { _ in .goToMain }
            .catch { .just(.showErrorAlert($0)) }
    }
}
