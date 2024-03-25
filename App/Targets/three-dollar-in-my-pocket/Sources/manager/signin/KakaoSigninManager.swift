import Combine

import AppInterface

import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

final class KakaoSigninManager: AppInterface.SigninManagerProtocol {
    static let shared = KakaoSigninManager()
    
    private var publisher = PassthroughSubject<String, Error>()
    
    func signin() -> PassthroughSubject<String, Error> {
        publisher = PassthroughSubject<String, Error>()
        
        if UserApi.isKakaoTalkLoginAvailable() {
            signinWithKakaoTalk()
        } else {
            signinWithKakaoAccount()
        }
        
        return publisher
    }
    
    func signout() -> Future<Void, Error> {
        return .init { promise in
            UserApi.shared.unlink { error in
                if let sdkError = error as? SdkError,
                   sdkError.getApiError().reason == .InvalidAccessToken {
                    promise(.success(()))
                } else if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    func logout() -> Future<Void, Error> {
        return .init { promise in
            UserApi.shared.logout { error in
                if let sdkError = error as? SdkError,
                   sdkError.getApiError().reason == .InvalidAccessToken {
                    promise(.success(()))
                } else if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    private func signinWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { [weak self] authToken, error in
            if let error = error {
                self?.handleError(error: error)
            } else {
                self?.handleAuthToken(authToken: authToken)
            }
        }
    }
    
    private func signinWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] authToken, error in
            if let error = error {
                self?.handleError(error: error)
            } else {
                self?.handleAuthToken(authToken: authToken)
            }
        }
    }
    
    private func handleError(error: Error) {
        if let sdkError = error as? SdkError {
            if sdkError.isClientFailed {
                let errorReason = sdkError.getClientError().reason
                if errorReason == .Cancelled {
                    return
                }
            }
        }
        
        publisher.send(completion: .failure(error))
    }
    
    private func handleAuthToken(authToken: OAuthToken?) {
        guard let authToken = authToken else { return }
        publisher.send(authToken.accessToken)
    }
}
