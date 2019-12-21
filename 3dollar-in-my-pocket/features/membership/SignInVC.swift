import UIKit
import KakaoOpenSDK
import NaverThirdPartyLogin
import AuthenticationServices
import GoogleSignIn

class SignInVC: BaseVC {
    
    private lazy var signInView = SignInView(frame: self.view.frame)
    
    
    static func instance() -> SignInVC {
        return SignInVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = signInView
        initializeGoogleSignIn()
        bindEvent()
    }
    
    private func bindEvent() {
        signInView.kakaoBtn.rx.tap
            .bind(onNext: requestKakaoSignIn).disposed(by: disposeBag)
        
        signInView.naverBtn.rx.tap
            .bind(onNext: requestNaverSignIn).disposed(by: disposeBag)
        
        signInView.appleBtn.rx.controlEvent(.touchUpInside)
            .bind(onNext: requestAppleSignIn).disposed(by: disposeBag)   
    }
    
    private func requestKakaoSignIn() {
        guard let kakaoSession = KOSession.shared() else {
            AlertUtils.show(message: "Kakao session is null")
            return
        }
        
        if kakaoSession.isOpen() {
            kakaoSession.close()
        }
        
        kakaoSession.open { (error) in
            print("kakao session open call")
            if let error = error {
                AlertUtils.show(title: "error", message: error.localizedDescription)
            } else {
                AlertUtils.show(title: "success", message: kakaoSession.token?.accessToken)
            }
        }
    }
    
    private func requestNaverSignIn() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        
        connection.delegate = self
        connection.requestThirdPartyLogin()
    }
    
    private func requestAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.performRequests()
    }
    
    private func initializeGoogleSignIn() {
        if let gidSignIn = GIDSignIn.sharedInstance() {
            gidSignIn.presentingViewController = self
            gidSignIn.delegate = self
        }
    }
}

extension SignInVC: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        AlertUtils.show(title: "success naver", message: "token: \(String(describing: connection.accessToken))")
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        AlertUtils.show(title: "이미 연결되어있음", message: "token: \(String(describing: connection.accessToken))")
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        AlertUtils.show(message: "oauth20ConnectionDidFinishDeleteToken()")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        AlertUtils.show(title: "error", message: error.localizedDescription)
    }
}

extension SignInVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AlertUtils.show(title: "error", message: error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            AlertUtils.show(title: "success", message: "token: \(appleIDCredential.user)")
        }
    }
}

extension SignInVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            AlertUtils.show(title: "error", message: "The user has not signed in before or they have since signed out.")
          } else {
            AlertUtils.show(title: "error", message: error.localizedDescription)
          }
        } else {
            AlertUtils.show(title: "success", message: "token: \(String(describing: user.authentication.idToken))")
        }
    }
}
