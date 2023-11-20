import Foundation
import Combine

import Networking
import Common
import Model
import Log

final class SigninViewModel: BaseViewModel {
    enum Route {
        case goToMain
        case pushNickname(SocialType, String)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    struct Input {
        let onTapSignin = PassthroughSubject<SocialType, Never>()
        let onTapSigninAnonymous = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .signIn
        let route = PassthroughSubject<Route, Never>()
    }
    
    let input = Input()
    let output = Output()
    private var appInterface = Environment.appModuleInterface
    private let userService: UserServiceProtocol
    private let deviceService: DeviceServiceProtocol
    private let logManager: LogManagerProtocol
    
    init(
        userService: UserServiceProtocol = UserService(),
        deviceService: DeviceServiceProtocol = DeviceService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.userService = userService
        self.deviceService = deviceService
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        input.onTapSignin
            .withUnretained(self)
            .sink { owner, socialType in
                owner.sendClickSignInLog(type: socialType)
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
        
        input.onTapSigninAnonymous
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendClickAnonymousLog()
                owner.output.route.send(.showLoading(isShow: true))
            })
            .asyncMap { owner, _ in
                await owner.userService.signinAnonymous()
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.route.send(.showLoading(isShow: false))
                
                switch result {
                case .success(let signinResponse):
                    owner.appInterface.userDefaults.userId = signinResponse.userId
                    owner.appInterface.userDefaults.authToken = signinResponse.token
                    owner.appInterface.userDefaults.isAnonymousUser = true
                    owner.output.route.send(.goToMain)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
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
            let result = await userService.signin(socialType: socialType.rawValue, accessToken: accessToken)
            
            switch result {
            case .success(let signinResponse):
                appInterface.userDefaults.userId = signinResponse.userId
                appInterface.userDefaults.authToken = signinResponse.token
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
    
    private func sendClickSignInLog(type: SocialType) {
        var eventName: EventName {
            switch type {
            case .kakao:
                return .clickSignInApple
                
            case .apple:
                return .clickSignInApple
                
            case .google:
                return .clickSignInAnonymous
                
            case .unknown:
                return .clickSignInAnonymous
            }
        }
        
        logManager.sendEvent(LogEvent(screen: output.screenName, eventName: eventName))
    }
    
    private func sendClickAnonymousLog() {
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickSignInAnonymous
        ))
    }
}
