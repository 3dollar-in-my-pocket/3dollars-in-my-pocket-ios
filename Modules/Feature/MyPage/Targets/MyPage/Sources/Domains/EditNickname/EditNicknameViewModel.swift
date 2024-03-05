import Combine

import Common
import Model
import Networking
import AppInterface

final class EditNicknameViewModel: BaseViewModel {
    struct Input {
        let inputNickname = PassthroughSubject<String, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let nickname: CurrentValueSubject<String, Never>
        let isEnableEditButton = PassthroughSubject<Bool, Never>()
        let isHiddenWarning = PassthroughSubject<Bool, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    private struct State {
        var nickname: String
    }
    
    struct Config {
        let nickname: String
    }
    
    enum Route {
        case pop
    }
    
    let input = Input()
    let output: Output
    private var state: State
    private let userService: UserServiceProtocol
    private let globalEventBus: GlobalEventBusProtocol
    
    init(
        config: Config,
        userService: UserServiceProtocol = UserService(),
        globalEventBus: GlobalEventBusProtocol = Environment.appModuleInterface.globalEventBus
    ) {
        self.output = Output(nickname: .init(config.nickname))
        self.state = State(nickname: config.nickname)
        self.userService = userService
        self.globalEventBus = globalEventBus
    }
    
    override func bind() {
        input.inputNickname
            .withUnretained(self)
            .sink { (owner: EditNicknameViewModel, nickname: String) in
                let isEnableEditButton = nickname.isNotEmpty
                
                owner.state.nickname = nickname
                owner.output.isEnableEditButton.send(isEnableEditButton)
                owner.output.isHiddenWarning.send(true)
            }
            .store(in: &cancellables)
        
        input.didTapEdit
            .withUnretained(self)
            .sink { (owner: EditNicknameViewModel, _) in
                owner.editNickname(nickname: owner.state.nickname)
            }
            .store(in: &cancellables)
    }
    
    private func editNickname(nickname: String) {
        Task {
            let result = await userService.editUser(nickname: nickname, representativeMedalId: nil)
            
            switch result {
            case .success(_):
                globalEventBus.onEditNickname.send(nickname)
                output.route.send(.pop)
                output.showToast.send(Strings.EditNickname.successEdit)
                
            case .failure(let error):
                if case let NetworkError.errorContainer(errorContainer) = error,
                   errorContainer.resultCode == "CF001" {
                    output.isHiddenWarning.send(false)
                } else {
                    output.showErrorAlert.send(error)
                }
            }
        }
        .store(in: taskBag)
    }
}
