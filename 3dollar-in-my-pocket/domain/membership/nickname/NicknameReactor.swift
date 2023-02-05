import ReactorKit
import RxSwift
import RxCocoa

final class NicknameReactor: BaseReactor, Reactor {
    enum Action {
        case inputNickname(String)
        case tapStartButton
    }
    
    enum Mutation {
        case setNickname(String)
        case setStartButtonEnable(Bool)
        case setErrorLabelHidden(Bool)
        case presentPolicy
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var nickname: String
        var isStartButtonEnable: Bool
        var isErrorLabelHidden: Bool
        @Pulse var presentPolicy: Void?
    }
    
    let initialState: State
    private let signinRequest: SigninRequest
    private var userDefaults: UserDefaultsUtil
    private let userService: UserServiceProtocol
    var isSignupSuccess = false
    
    init(
        signinRequest: SigninRequest,
        userDefaults: UserDefaultsUtil,
        userService: UserServiceProtocol,
        state: State = State(
            nickname: "",
            isStartButtonEnable: false,
            isErrorLabelHidden: true
        )
    ) {
        self.signinRequest = signinRequest
        self.userDefaults = userDefaults
        self.userService = userService
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNickname(let nickname):
            let isStartButtonEnable = !nickname.trimmingCharacters(in: .whitespaces).isEmpty
            
            return .merge([
                .just(.setNickname(nickname)),
                .just(.setStartButtonEnable(isStartButtonEnable))
            ])
            
        case .tapStartButton:
            let nickname = self.currentState.nickname
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.setNickname(nickname: nickname),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNickname(let nickname):
            newState.nickname = nickname
            
        case .setStartButtonEnable(let isEnable):
            newState.isStartButtonEnable = isEnable
            
        case .setErrorLabelHidden(let isHidden):
            newState.isErrorLabelHidden = isHidden
            
        case .presentPolicy:
            newState.presentPolicy = ()
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func setNickname(nickname: String) -> Observable<Mutation> {
        let signupRequest = SignupRequest(
            name: nickname,
            socialType: self.signinRequest.socialType,
            token: self.signinRequest.token
        )
        
        if self.isSignupSuccess {
            return .just(.presentPolicy)
        } else {
            return self.userService.signup(request: signupRequest)
                .do(onNext: { [weak self] response in
                    self?.userDefaults.userId = response.userId
                    self?.userDefaults.authToken = response.token
                    self?.isSignupSuccess = true
                })
                .map { _ in .presentPolicy }
                .catch { [weak self] error in
                    return self?.handleSignupError(error: error)
                    ?? .just(.showErrorAlert(error: BaseError.unknown))
                }
        }
    }
  
    private func handleSignupError(error: Error) -> Observable<Mutation> {
        if let signupError = error as? SignupError {
            switch signupError {
            case .alreadyExistedNickname:
                return .just(.setErrorLabelHidden(false))
                
            case .badRequest:
                let error = BaseError.custom(signupError.errorDescription ?? "")
                
                return .just(.showErrorAlert(error: error))
            }
        } else {
            return .just(.showErrorAlert(error: error))
        }
    }
}
