import Foundation
import Combine

import Networking
import Common
import Model
import Log

final class SigninViewModel: BaseViewModel {
    enum Constant {
        static let presentDemoCodeAlertCount = 5
    }
    
    enum Route {
        case goToMain
        case pushNickname(SocialType, String)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
        case presentDemoCodeAlert
    }
    
    struct Input {
        let signinDemo = PassthroughSubject<String, Never>()
        let signinWithSocial = PassthroughSubject<SocialType, Never>()
        let signinAnonymous = PassthroughSubject<Void, Never>()
        let didTapLogo = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .signIn
        let route = PassthroughSubject<Route, Never>()
    }
    
    private struct State {
        var logoTouchCount = 0
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
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
        input.signinDemo
            .withUnretained(self)
            .sink { (owner: SigninViewModel, code: String) in
                owner.signinDemo(code: code)
            }
            .store(in: &cancellables)
        
        input.signinWithSocial
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
        
        input.signinAnonymous
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
        
        input.didTapLogo
            .withUnretained(self)
            .sink { (owner: SigninViewModel, _) in
                owner.state.logoTouchCount += 1
                
                if owner.state.logoTouchCount >= Constant.presentDemoCodeAlertCount {
                    owner.output.route.send(.presentDemoCodeAlert)
                    owner.state.logoTouchCount = 0
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
    
    private func signinDemo(code: String) {
        output.route.send(.showLoading(isShow: true))
        
        Task {
            let result = await userService.signinDemo(code: code)
            
            switch result {
            case .success(let response):
                appInterface.userDefaults.userId = response.userId
                appInterface.userDefaults.authToken = response.token
                output.route.send(.goToMain)
                
            case .failure(let error):
                output.route.send(.showLoading(isShow: false))
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }
}


// MARK: Log
extension SigninViewModel {
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
