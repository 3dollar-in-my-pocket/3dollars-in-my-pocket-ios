import ReactorKit
import RxSwift
import RxCocoa

final class EditNicknameReactor: BaseReactor, Reactor {
    enum Action {
        case inputNickname(String)
        case tapEditNickname
    }
    
    enum Mutation {
        case setNickname(String)
        case setEnableEditButton(Bool)
        case setHiddenWarning(isHidden: Bool)
        case pop
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var nickname: String
        var isEnableEditButton: Bool
        var isHiddenWarning: Bool
        @Pulse var pop: Void?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let globalState: GlobalState
    
    init(
        userService: UserServiceProtocol,
        globalState: GlobalState,
        state: State = State(nickname: "", isEnableEditButton: false, isHiddenWarning: true)
    ) {
        self.userService = userService
        self.globalState = globalState
        self.initialState = state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputNickname(let nickname):
            return .merge([
                .just(.setNickname(nickname)),
                .just(.setEnableEditButton(!nickname.isEmpty)),
                .just(.setHiddenWarning(isHidden: true))
            ])
            
        case .tapEditNickname:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.editNickname(nickname: self.currentState.nickname),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNickname(let nickname):
            newState.nickname = nickname
            
        case .setEnableEditButton(let isEnable):
            newState.isEnableEditButton = isEnable
            
        case .setHiddenWarning(let isHidden):
            newState.isHiddenWarning = isHidden
            
        case .pop:
            newState.pop = ()
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func editNickname(nickname: String) -> Observable<Mutation> {
        return self.userService.editNickname(name: nickname)
            .do(onNext: { [weak self] _ in
                self?.globalState.updateNickname.onNext(nickname)
            })
            .map { _ in .pop }
            .catch { error in
                if let editNicknameError = error as? EditNicknameError {
                    switch editNicknameError {
                    case .alreadyExistedNickname:
                        return .just(.setHiddenWarning(isHidden: false))
                        
                    case .badRequest:
                        return .just(.showErrorAlert(editNicknameError))
                    }
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
}
