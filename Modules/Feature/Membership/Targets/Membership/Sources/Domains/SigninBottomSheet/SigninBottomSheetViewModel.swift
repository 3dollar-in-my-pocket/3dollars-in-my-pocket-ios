import Foundation
import Combine

import Common
import Model
import Networking
import AppInterface

final class SigninBottomSheetViewModel: BaseViewModel {
    struct Input {
        let signinWithSocial = PassthroughSubject<SocialType, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case goToMain
        case pushNickname(SocialType, String)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    let input = Input()
    let output = Output()
    private var appInterface = Environment.appModuleInterface
    private let userRepository: UserRepository
    private let deviceService: DeviceServiceProtocol
    private var preference = Preference.shared
    
    init(
        userRepository: UserRepository = UserRepositoryImpl(),
        deviceService: DeviceServiceProtocol = DeviceService()
    ) {
        self.userRepository = userRepository
        self.deviceService = deviceService
        
        super.init()
    }
    
    override func bind() {
        input.signinWithSocial
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
    }
    
    private func signinWithKakao() {
        appInterface.kakaoSigninManager.signin()
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.route.send(.showLoading(isShow: true))
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    self?.output.route.send(.showErrorAlert(error))
                    self?.output.route.send(.showLoading(isShow: false))
                }
            } receiveValue: { owner, accessToken in
                owner.signin(socialType: .kakao, accessToken: accessToken)
            }
            .store(in: &cancellables)
    }
    
    private func signinWithApple() {
        appInterface.appleSigninManager.signin()
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
                owner.signin(socialType: .apple, accessToken: accessToken)
            }
            .store(in: &cancellables)
    }
    
    private func signin(socialType: SocialType, accessToken: String) {
        Task {
            let input = SigninRequestInput(socialType: socialType.rawValue, token: accessToken)
            let result = await userRepository.signin(input: input)
            
            switch result {
            case .success(let signinResponse):
                preference.userId = signinResponse.userId
                preference.authToken = signinResponse.token
                sendFCMToken(socialType: socialType)
                
            case .failure(let error):
                output.route.send(.showLoading(isShow: false))
                
                if let networkError = error as? NetworkError,
                   case .errorContainer(let errorContainer) = networkError {
                    if errorContainer.resultCode == "NF001" {
                        output.route.send(.pushNickname(socialType, accessToken))
                    } else {
                        output.route.send(.showErrorAlert(error))
                    }
                } else {
                    output.route.send(.showErrorAlert(error))
                }
            }
        }
    }
    
    private func sendFCMToken(socialType: SocialType) {
        appInterface.getFCMToken { [weak self] token in
            guard let self = self else { return }
            
            Task {
                let refreshDevice = await self.deviceService.refreshDevice(pushToken: token)
                
                self.output.route.send(.showLoading(isShow: false))
                
                switch refreshDevice {
                case .success(_):
                    self.output.route.send(.goToMain)
                    
                case .failure(let error):
                    self.output.route.send(.showErrorAlert(error))
                }
            }
        }
    }
}
