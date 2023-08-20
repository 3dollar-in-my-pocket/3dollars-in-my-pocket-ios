import AuthenticationServices
import Combine

final class NewAppleSigninManager: NSObject, NewSigninManagerProtocol {
    private var publisher = PassthroughSubject<String, Error>()
    
    deinit {
        publisher.send(completion: .finished)
    }
    
    func signin() -> PassthroughSubject<String, Error> {
        publisher = PassthroughSubject<String, Error>()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.performRequests()
        return publisher
    }
    
    func signout() -> Future<Void, Error> {
        // 애플에서는 회원탈퇴 API를 제공하지 않습니다.
        return .init { promise in
            promise(.success(()))
        }
    }
    
    func logout() -> Future<Void, Error> {
        // 애플에서는 로그아웃 API를 제공하지 않습니다.
        return .init { promise in
            promise(.success(()))
        }
    }
}

extension NewAppleSigninManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authorizationError = error as? ASAuthorizationError {
            switch authorizationError.code {
            case .canceled:
                publisher.send(completion: .failure(BaseError.custom("cancel")))
                
            case .failed, .invalidResponse, .notHandled, .unknown:
                let error = BaseError.custom(authorizationError.localizedDescription)
                
                publisher.send(completion: .failure(error))
            default:
                let error = BaseError.custom(error.localizedDescription)
                
                publisher.send(completion: .failure(error))
            }
        } else {
            let error = BaseError.custom(
                "error is instance of \(error.self). not ASAuthorizationError"
            )
            
            publisher.send(completion: .failure(error))
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let accessToken = String(
            data: appleIDCredential.identityToken!,
            encoding: .utf8
           ) {
            publisher.send(accessToken)
            publisher.send(completion: .finished)
        } else {
            let signInError = BaseError.custom(
                "credential is not ASAuthorizationAppleIDCredential"
            )
            
            publisher.send(completion: .failure(signInError))
        }
    }
}
