import Foundation
import Combine

import Networking
import Common

import FirebaseMessaging

final class SigninViewModel: Common.BaseViewModel {
    enum Route {
        case goToMain
        case pushNickname(SocialType, String)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    struct Input {
        let onTapSignin = PassthroughSubject<SocialType, Never>()
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
    private let deviceService: Networking.DeviceProtocol
    
    init(
        userDefaults: UserDefaultsUtil = UserDefaultsUtil(),
        kakaoManager: NewKakaoSigninManager = .init(),
        appleManager: NewAppleSigninManager = .init(),
        userService: Networking.UserServiceProtocol = Networking.UserService(),
        deviceService: Networking.DeviceProtocol = Networking.DeviceService()
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
                    self?.output.route.send(.showErrorAlert(error))
                    self?.output.route.send(.showLoading(isShow: false))
                }
            } receiveValue: { owner, accessToken in
                owner.signin(socialType: .kakao, accessToken: accessToken)
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
                    self?.output.route.send(.showErrorAlert(error))
                    self?.output.route.send(.showLoading(isShow: false))
                }
            } receiveValue: { owner, accessToken in
                owner.signin(socialType: .apple, accessToken: accessToken)
            }
            .store(in: &cancellables)
    }
    
    private func signin(socialType: SocialType, accessToken: String) {
        Task {
            let result = await userService.signin(socialType: socialType.value, accessToken: accessToken)
            
            switch result {
            case .success(let signinResponse):
                userDefaults.userId = signinResponse.userId
                userDefaults.authToken = signinResponse.token
                sendFCMToken(socialType: socialType)
                
            case .failure(let error):
                if let httpError = error as? Networking.HTTPError,
                   httpError == .notFound {
                    output.route.send(.pushNickname(socialType, accessToken))
                } else {
                    output.route.send(.showErrorAlert(error))
                }
            }
        }
    }
    
    private func sendFCMToken(socialType: SocialType) {
        Messaging.messaging().token { [weak self] token, error in
            guard let self = self else { return }
            
            if let token = token {
                Task {
                    let refreshDevice = await self.deviceService.refreshDevice(pushToken: token)
                    
                    switch refreshDevice {
                    case .success(_):
                        self.output.route.send(.goToMain)
                        
                    case .failure(let error):
                        self.output.route.send(.showErrorAlert(error))
                    }
                }
            } else {
                print("💜Error in send FCM token")
            }
        }
    }
    
//    private func signinAnonymous() -> Observable<Mutation> {
//        return self.userService.signinAnonymous()
//            .do(onNext: { [weak self] signinResponse in
//                self?.userDefaults.userId = signinResponse.userId
//                self?.userDefaults.authToken = signinResponse.token
//                self?.userDefaults.isAnonymousUser = true
//            })
//            .map { _ in .goToMain }
//            .catch { .just(.showErrorAlert($0)) }
//    }
}
