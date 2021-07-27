import RxKakaoSDKUser
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import RxSwift

class KakaoSigninManager: SigninManagerProtocol {
  
  private var disposeBag = DisposeBag()
  private var publisher = PublishSubject<SigninRequest>()
  
  
  deinit {
    self.publisher.onCompleted()
  }
  
  func signIn() -> Observable<SigninRequest> {
    self.publisher = PublishSubject<SigninRequest>()
    
    if UserApi.isKakaoTalkLoginAvailable() {
      self.signInWithKakaoTalk()
    } else {
      self.signInWithKakaoAccount()
    }
    return self.publisher
  }
  
  func signOut() -> Completable {
    return UserApi.shared.rx.logout()
  }
  
  func unlink() -> Completable {
    return UserApi.shared.rx.unlink()
  }
  
  private func signInWithKakaoTalk() {
    UserApi.shared.rx.loginWithKakaoTalk()
      .subscribe { authToken in
        let request = SigninRequest(socialType: .KAKAO, token: authToken.accessToken)
        
        self.publisher.onNext(request)
        self.publisher.onCompleted()
      } onError: { error in
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
          let signInError = BaseError.custom("error is not SdkError. (\(error.self))")
          
          self.publisher.onError(signInError)
        }
      }.disposed(by: self.disposeBag)
  }
  
  private func signInWithKakaoAccount() {
    UserApi.shared.rx.loginWithKakaoAccount()
      .subscribe { authToken in
        let request = SigninRequest(socialType: .KAKAO, token: authToken.accessToken)
        
        self.publisher.onNext(request)
        self.publisher.onCompleted()
      } onError: { error in
        self.publisher.onError(error)
      }
      .disposed(by: self.disposeBag)
  }
}
