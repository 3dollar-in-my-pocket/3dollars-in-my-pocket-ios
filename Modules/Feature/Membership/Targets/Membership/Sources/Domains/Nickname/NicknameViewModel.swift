import Foundation
import Combine

import Common
import Networking
import Model
import AppInterface
import DependencyInjection

final class NicknameViewModel: BaseViewModel {
    struct Input {
        let inputNickname = PassthroughSubject<String, Never>()
        let onTapSigninButton = PassthroughSubject<Void, Never>()
        let onDismissPolicy = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let isEnableSignupButton = PassthroughSubject<Bool, Never>()
        let isHiddenWarningLabel = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var nickname = ""
        var socialType: SocialType
        var accessToken: String
        var isSignupSuccess = false
        var bookmarkFolderId: String?
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
    private let userService: Networking.UserServiceProtocol
    
    init(
        socialType: SocialType,
        accessToken: String,
        bookmarkFolderId: String? = nil,
        userService: Networking.UserServiceProtocol = Networking.UserService()
    ) {
        guard let appInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("⚠️ AppModuleInterface가 등록되지 않았습니다.")
        }
        
        self.state = State(socialType: socialType, accessToken: accessToken)
        self.appInterface = appInterface
        self.userService = userService
    }
    
    override func bind() {
        input.inputNickname
            .withUnretained(self)
            .print("💜nickname")
            .sink(receiveValue: { owner, nickname in
                let isEnableSignup = nickname.trimmingCharacters(in: .whitespaces).isNotEmpty
                
                owner.state.nickname = nickname
                owner.output.isEnableSignupButton.send(isEnableSignup)
            })
            .store(in: &cancellables)
        
        input.onTapSigninButton
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                if owner.state.isSignupSuccess {
                    owner.output.route.send(.presentPolicy)
                } else {
                    owner.output.route.send(.showLoading(isShow: true))
                    owner.signup()
                }
            })
            .store(in: &cancellables)
        
        input.onDismissPolicy
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.route.send(.goToMain(bookmarkFolderId: owner.state.bookmarkFolderId))
            }
            .store(in: &cancellables)
    }
    
    private func signup() {
        Task {
            let result = await userService.signup(
                name: state.nickname,
                socialType: state.socialType.rawValue,
                token: state.accessToken
            )
            
            switch result {
            case .success(let signupResponse):
                appInterface.userDefaults.userId = signupResponse.userId
                appInterface.userDefaults.authToken = signupResponse.token
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
}
