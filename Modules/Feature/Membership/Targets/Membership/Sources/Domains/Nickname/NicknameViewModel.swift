import Foundation
import Combine

import Common
import Networking
import Model
import AppInterface
import Log

final class NicknameViewModel: BaseViewModel {
    struct Input {
        let inputNickname = PassthroughSubject<String, Never>()
        let onTapSigninButton = PassthroughSubject<Void, Never>()
        let onDismissPolicy = PassthroughSubject<Void, Never>()
        let onTapRefreshButton = PassthroughSubject<Void, Never>()
        let onTapNameField = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .signUp
        let isEnableSignupButton = PassthroughSubject<Bool, Never>()
        let isHiddenWarningLabel = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
        let setRandomName = PassthroughSubject<String, Never>()
        let clearNameField = PassthroughSubject<Void, Never>()
    }
    
    struct State {
        var nickname: String
        var socialType: SocialType
        var accessToken: String
        var isSignupSuccess = false
        var bookmarkFolderId: String?
        var isRandomName: Bool
    }
    
    enum Route {
        case presentPolicy
        case goToMain(bookmarkFolderId: String?)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private var appInterface: AppModuleInterface
    private let userRepository: UserRepository
    private let logManager: LogManagerProtocol
    private var preference = Preference.shared
    
    init(
        socialType: SocialType,
        accessToken: String,
        bookmarkFolderId: String? = nil,
        randomName: String?,
        appInterface: AppModuleInterface = Environment.appModuleInterface,
        userRepository: UserRepository = UserRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.state = State(nickname: randomName ?? "", socialType: socialType, accessToken: accessToken, isRandomName: (randomName ?? "").isNotEmpty)
        self.appInterface = appInterface
        self.userRepository = userRepository
        self.logManager = logManager
    }
    
    override func bind() {
        input.inputNickname
            .withUnretained(self)
            .sink(receiveValue: { owner, nickname in
                let isEnableSignup = nickname.trimmingCharacters(in: .whitespaces).isNotEmpty
                
                owner.state.nickname = nickname
                owner.state.isRandomName = false
                owner.output.isEnableSignupButton.send(isEnableSignup)
            })
            .store(in: &cancellables)
        
        input.onTapSigninButton
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.sendSignupLog()
                if owner.state.isSignupSuccess {
                    owner.output.route.send(.presentPolicy)
                } else {
                    owner.output.route.send(.showLoading(isShow: true))
                    if owner.state.isRandomName {
                        owner.signupWithRandomName()
                    } else {
                        owner.signup()
                    }
                }
            })
            .store(in: &cancellables)
        
        input.onDismissPolicy
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.route.send(.goToMain(bookmarkFolderId: owner.state.bookmarkFolderId))
            }
            .store(in: &cancellables)
        
        input.onTapRefreshButton
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.createRandomName()
            })
            .store(in: &cancellables)
        
        input.onTapNameField
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                if owner.state.isRandomName {
                    owner.state.isRandomName = false
                    owner.state.nickname = ""
                    owner.output.clearNameField.send()
                    owner.output.isEnableSignupButton.send(false)
                }
            })
            .store(in: &cancellables)
    }
    
    private func signup() {
        Task {
            let input = SignupInput(name: state.nickname, socialType: state.socialType.rawValue, token: state.accessToken)
            let result = await userRepository.signup(input: input)
            
            switch result {
            case .success(let signupResponse):
                preference.userId = signupResponse.userId
                preference.authToken = signupResponse.token
                state.isSignupSuccess = true
                output.route.send(.showLoading(isShow: false))
                output.route.send(.presentPolicy)
                
            case .failure(let error):
                output.route.send(.showLoading(isShow: false))
                handleSignupError(error: error)
            }
        }
    }
    
    private func signupWithRandomName() {
        Task {
            let input = SignupInput(name: state.nickname, socialType: state.socialType.rawValue, token: state.accessToken)
            let result = await userRepository.signupWithRandomName(input: input)
            
            switch result {
            case .success(let signupResponse):
                preference.userId = signupResponse.userId
                preference.authToken = signupResponse.token
                state.isSignupSuccess = true
                output.route.send(.showLoading(isShow: false))
                output.route.send(.presentPolicy)
                
            case .failure(let error):
                output.route.send(.showLoading(isShow: false))
                handleSignupError(error: error)
            }
        }
    }
    
    private func handleSignupError(error: Error) {
        if let networkError = error as? NetworkError,
           case .errorContainer(let errorContainer) = networkError {
            if errorContainer.resultCode == "CF001" {
                output.isHiddenWarningLabel.send(false)
            } else {
                output.route.send(.showErrorAlert(error))
            }
        } else {
            output.route.send(.showErrorAlert(error))
        }
    }
    
    private func sendSignupLog() {
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickSignUp,
            extraParameters: [.nickname: state.nickname]
        ))
    }
    
    private func createRandomName() {
        Task {
            output.route.send(.showLoading(isShow: true))
            let result = await userRepository.createRandomName()
            output.route.send(.showLoading(isShow: false))
            
            switch result {
            case .success(let response):
                if let name = response.contents.first?.name {
                    state.isRandomName = true
                    state.nickname = name
                    output.setRandomName.send(name)
                    output.isEnableSignupButton.send(true)
                }
            case .failure:
                break
            }
        }
    }
}
