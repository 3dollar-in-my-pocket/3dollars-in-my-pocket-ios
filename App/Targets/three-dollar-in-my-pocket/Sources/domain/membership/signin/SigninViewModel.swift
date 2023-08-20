import Foundation
import Combine

import Networking
import Common

final class SigninViewModel: Common.BaseViewModel {
    enum SigninType {
        case kakao
        case apple
    }
    
    enum Route {
        case goToMain
        case pushNickname(SigninRequest)
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
    }
    
    struct Input {
        let onTapSignin = PassthroughSubject<SigninType, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    let input = Input()
    let output = Output()
    private var userDefaults: UserDefaultsUtil
    private let kakaoManager: NewKakaoSigninManager
    private let appleManager: NewAppleSigninManager
    
    init(
        userDefaults: UserDefaultsUtil = UserDefaultsUtil(),
        kakaoManager: NewKakaoSigninManager = .init(),
        appleManager: NewAppleSigninManager = .init()
    ) {
        self.userDefaults = userDefaults
        self.kakaoManager = kakaoManager
        self.appleManager = appleManager
        
        super.init()
    }
    
    override func bind() {
        input.onTapSignin
            .withUnretained(self)
            .sink { owner, signinType in
                switch signinType {
                case .kakao:
                    owner.signinWithKakao()
                    
                case .apple:
                    owner.signinWithApple()
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
                let signinRequest = SigninRequest(socialType: .kakao, token: accessToken)
                
                owner.output.route.send(.pushNickname(signinRequest))
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
                let signinRequest = SigninRequest(socialType: .kakao, token: accessToken)
                
                owner.output.route.send(.pushNickname(signinRequest))
            }
            .store(in: &cancellables)
    }
}
