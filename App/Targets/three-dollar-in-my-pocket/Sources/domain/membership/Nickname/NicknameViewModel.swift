import Foundation
import Combine

import Common
import Networking

final class NicknameViewModel: Common.BaseViewModel {
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
    private var userDefaults: UserDefaultsUtil
    private let userService: Networking.UserServiceProtocol
    
    init(
        socialType: SocialType,
        accessToken: String,
        userDefaults : UserDefaultsUtil = .init(),
        userService: Networking.UserServiceProtocol = Networking.UserService()
    ) {
        self.state = State(socialType: socialType, accessToken: accessToken)
        self.userDefaults = userDefaults
        self.userService = userService
    }
    
    override func bind() {
        input.inputNickname
            .withUnretained(self)
            .sink(receiveValue: { owner, nickname in
                let isEnableSignup = owner.state.nickname.trimmingCharacters(in: .whitespaces).isEmpty
                
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
                userDefaults.userId = signupResponse.userId
                userDefaults.authToken = signupResponse.token
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
        if let httpError = error as? Networking.HTTPError {
            switch httpError {
            case .conflict:
                output.isHiddenWarningLabel.send(false)
                
            case .badRequest:
                let error = BaseError.custom("잘못된 형식의 닉네임입니다.")
                output.route.send(.showErrorAlert(error))
                
            default:
                output.route.send(.showErrorAlert(error))
            }
        } else {
            output.route.send(.showErrorAlert(error))
        }
    }
}
