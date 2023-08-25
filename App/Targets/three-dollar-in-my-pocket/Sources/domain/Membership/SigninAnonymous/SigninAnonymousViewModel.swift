import Foundation
import Combine

import Networking
import Common

final class SigninAnonymousViewModel: Common.BaseViewModel {
    enum Route {
        case dismiss
        case showAlreadyExist(SigninRequest)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    struct Input {
        let onTapSignin = PassthroughSubject<SocialType, Never>()
        let signin = PassthroughSubject<SigninRequest, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    let input = Input()
    let output = Output()
    private var userDefaults: UserDefaultsUtil
    private let kakaoManager: NewKakaoSigninManager
    private let appleManager: NewAppleSigninManager
    private let userService: Networking.UserServiceProtocol
    private let deviceService: Networking.DeviceServiceProtocol
    
    init(
        userDefaults: UserDefaultsUtil = UserDefaultsUtil(),
        kakaoManager: NewKakaoSigninManager = .init(),
        appleManager: NewAppleSigninManager = .init(),
        userService: Networking.UserServiceProtocol = Networking.UserService(),
        deviceService: Networking.DeviceServiceProtocol = Networking.DeviceService()
    ) {
        self.userDefaults = userDefaults
        self.kakaoManager = kakaoManager
        self.appleManager = appleManager
        self.userService = userService
        self.deviceService = deviceService
        
        super.init()
    }
    
    override func bind() {
        input.onTapSignin
            .withUnretained(self)
            .sink { owner, socialType in
                switch socialType {
                case .kakao:
                    owner.signinWithKakao()
                    
                case .apple:
                    owner.signinWithApple()
                    
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        input.signin
            .withUnretained(self)
            .sink { owner, signinRequest in
                owner.signin(signinRequest)
            }
            .store(in: &cancellables)
    }
    
    private func signinWithKakao() {
        kakaoManager.signin()
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.route.send(.showLoading(isShow: true))
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    self?.output.route.send(.showLoading(isShow: false))
                    self?.output.route.send(.showErrorAlert(error))
                }
            } receiveValue: { owner, accessToken in
                owner.connectAccount(socialType: .kakao, accessToken: accessToken)
            }
            .store(in: &cancellables)
    }
    
    private func signinWithApple() {
        appleManager.signin()
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.route.send(.showLoading(isShow: true))
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    self?.output.route.send(.showLoading(isShow: false))
                    self?.output.route.send(.showErrorAlert(error))
                }
            } receiveValue: { owner, accessToken in
                owner.connectAccount(socialType: .apple, accessToken: accessToken)
            }
            .store(in: &cancellables)
    }
    
    private func connectAccount(socialType: SocialType, accessToken: String) {
        Task {
            let connectAccount = await userService.connectAccount(socialType: socialType.rawValue, accessToken: accessToken)
            
            switch connectAccount {
            case .success(_):
                userDefaults.isAnonymousUser = false
                output.route.send(.showLoading(isShow: false))
                output.route.send(.dismiss)
                
            case .failure(let error):
                if let networkError = error as? NetworkError,
                   case .errorContainer(let errorContainer) = networkError {
                    if errorContainer.resultCode == "CF002" {
                        let signinRequest = SigninRequest(socialType: socialType, token: accessToken)
                        output.route.send(.showAlreadyExist(signinRequest))
                    } else {
                        output.route.send(.showErrorAlert(error))
                    }
                    
                }
            }
        }
    }
    
    private func signin(_ signinRequest: SigninRequest) {
        Task {
            let result = await userService.signin(
                socialType: signinRequest.socialType.value,
                accessToken: signinRequest.token
            )
            
            switch result {
            case .success(let signinResponse):
                userDefaults.userId = signinResponse.userId
                userDefaults.authToken = signinResponse.token
                userDefaults.isAnonymousUser = false
                output.route.send(.showLoading(isShow: false))
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.route.send(.showLoading(isShow: false))
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
