import AuthenticationServices
import RxSwift

class AppleSigninManager: NSObject, SigninManagerProtocol {
  
  private var publisher = PublishSubject<SigninRequest>()
  
  
  deinit {
    self.publisher.onCompleted()
  }
  
  func signIn() -> Observable<SigninRequest> {
    self.publisher = PublishSubject<SigninRequest>()
    
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    
    request.requestedScopes = [.fullName, .email]
    
    let authController = ASAuthorizationController(authorizationRequests: [request])
    
    authController.delegate = self
    authController.performRequests()
    
    return self.publisher
  }
}

extension AppleSigninManager: ASAuthorizationControllerDelegate {
  
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    if let authorizationError = error as? ASAuthorizationError {
      switch authorizationError.code {
      case .canceled:
        break
      case .failed, .invalidResponse, .notHandled, .unknown:
        let error = BaseError.custom(authorizationError.localizedDescription)
        
        self.publisher.onError(error)
      default:
        let error = BaseError.custom(error.localizedDescription)
        
        self.publisher.onError(error)
      }
    } else {
      let error = BaseError.custom("error is instance of \(error.self). not ASAuthorizationError")
      
      self.publisher.onError(error)
    }
  }
  
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
       let accessToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) {
      self.publisher.onNext(SigninRequest(socialType: .APPLE, token: accessToken))
      self.publisher.onCompleted()
    } else {
      let signInError = BaseError.custom("credential is not ASAuthorizationAppleIDCredential")
      
      self.publisher.onError(signInError)
    }
  }
}
