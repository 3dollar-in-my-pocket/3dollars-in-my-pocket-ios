import ReactorKit

final class SigninAnonymousReactor: Reactor {
    enum Action {
        case tapKakaoButton
        case tapAppleButton
    }
    
    enum Mutation {
        case dismiss
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    struct State {
        @Pulse var dismiss: Void?
        @Pulse var showErrorAlert: Error?
        @Pulse var showLoading: Bool?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private var userDefaults: UserDefaultsUtil
    private let kakaoManager: SigninManagerProtocol
    private let appleManager: SigninManagerProtocol
    
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
        case .dismiss:
            newState.dismiss = ()
            
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
                
                return self.connectAccount(request: signinRequest)
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func signinWithApple() -> Observable<Mutation> {
        return self.appleManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.connectAccount(request: signinRequest)
            }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func connectAccount(request: SigninRequest) -> Observable<Mutation> {
        return self.userService.connectAccount(request: request)
            .do(onNext: { [weak self] _ in
                self?.userDefaults.isAnonymousUser = false
            })
            .map { _ in .dismiss }
            .catch { .just(.showErrorAlert($0)) }
    }
}
