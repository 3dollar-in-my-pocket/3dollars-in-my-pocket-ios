import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import RxSwift

final class KakaoSigninManager: SigninManagerProtocol {
    private var disposeBag = DisposeBag()
    private var publisher = PublishSubject<SigninRequest>()
    
    deinit {
        self.publisher.onCompleted()
    }
    
    func signin() -> Observable<SigninRequest> {
        self.publisher = PublishSubject<SigninRequest>()
        
        if UserApi.isKakaoTalkLoginAvailable() {
            self.signInWithKakaoTalk()
        } else {
            self.signInWithKakaoAccount()
        }
        return self.publisher
    }
    
    func signout() -> Observable<Void> {
        return .create { observer in
            UserApi.shared.unlink { error in
                if let kakaoError = error as? SdkError,
                   kakaoError.getApiError().reason == .InvalidAccessToken {
                    // KAKAO 토큰이 사라진 경우: 개발서버앱으로 왔다갔다 하는경우?
                    observer.onNext(())
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Void> {
        return .create { observer in
            UserApi.shared.logout { error in
                if let kakaoError = error as? SdkError,
                   kakaoError.getApiError().reason == .InvalidAccessToken {
                    // KAKAO 토큰이 사라진 경우: 개발서버앱으로 왔다갔다 하는경우?
                    observer.onNext(())
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    private func signInWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { authToken, error in
            if let error = error {
                if let sdkError = error as? SdkError {
                    if sdkError.isClientFailed {
                        switch sdkError.getClientError().reason {
                        case .Cancelled:
                            self.publisher.onError(BaseError.custom("cancel"))
                        default:
                            let errorMessage = sdkError.getApiError().info?.msg ?? ""
                            let error = BaseError.custom(errorMessage)
                            
                            self.publisher.onError(error)
                        }
                    }
                } else {
                    let signInError
                    = BaseError.custom("error is not SdkError. (\(error.self))")
                    
                    self.publisher.onError(signInError)
                }
            } else {
                guard let authToken = authToken else {
                    self.publisher.onError(BaseError.custom("authToken is nil"))
                    return
                }
                let request = SigninRequest(
                    socialType: .kakao,
                    token: authToken.accessToken
                )
                
                self.publisher.onNext(request)
                self.publisher.onCompleted()
            }
        }
    }
    
    private func signInWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { authToken, error in
            if let error = error {
                if let sdkError = error as? SdkError {
                    if sdkError.isClientFailed {
                        switch sdkError.getClientError().reason {
                        case .Cancelled:
                            break
                        default:
                            let errorMessage = sdkError.getApiError().info?.msg ?? ""
                            let error = BaseError.custom(errorMessage)
                            
                            self.publisher.onError(error)
                        }
                    }
                } else {
                    let signInError
                    = BaseError.custom("error is not SdkError. (\(error.self))")
                    
                    self.publisher.onError(signInError)
                }
            } else {
                guard let authToken = authToken else {
                    self.publisher.onError(BaseError.custom("authTOken is nil"))
                    return
                }
                
                let request = SigninRequest(
                    socialType: .kakao,
                    token: authToken.accessToken
                )
                
                self.publisher.onNext(request)
                self.publisher.onCompleted()
            }
        }
    }
}
