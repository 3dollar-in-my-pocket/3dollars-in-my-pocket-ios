import Foundation
import Combine

import Networking
import Common
import Model
import AppInterface
import DependencyInjection

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
    private var appInterface: AppModuleInterface?
    private let userRepository: UserRepository
    private let deviceService: Networking.DeviceServiceProtocol
    private var preference = Preference.shared
    
    init(
        userRepository: UserRepository = UserRepositoryImpl(),
        deviceService: Networking.DeviceServiceProtocol = Networking.DeviceService()
    ) {
        self.appInterface = DIContainer.shared.container.resolve(AppModuleInterface.self)
        self.userRepository = userRepository
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
        appInterface?.kakaoSigninManager.signin()
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
        appInterface?.appleSigninManager.signin()
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
            let input = SigninRequestInput(socialType: socialType.rawValue, token: accessToken)
            let connectAccount = await userRepository.connectAccount(input: input)
            
            switch connectAccount {
            case .success(_):
                preference.isAnonymousUser = false
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
            let input = SigninRequestInput(socialType: signinRequest.socialType.rawValue, token: signinRequest.token)
            let result = await userRepository.signin(input: input)
            
            switch result {
            case .success(let signinResponse):
                preference.userId = signinResponse.userId
                preference.authToken = signinResponse.token
                preference.isAnonymousUser = false
                output.route.send(.showLoading(isShow: false))
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.route.send(.showLoading(isShow: false))
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
