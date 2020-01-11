import UIKit
import KakaoOpenSDK
import AuthenticationServices

class SignInVC: BaseVC {
    
    private lazy var signInView = SignInView(frame: self.view.frame)
    
    
    static func instance() -> UINavigationController {
        let controller = SignInVC(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: controller)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = signInView
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func bindViewModel() {
        signInView.kakaoBtn.rx.tap
            .bind(onNext: requestKakaoSignIn).disposed(by: disposeBag)
        
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
    
    private func requestAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.performRequests()
    }
}
extension SignInVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AlertUtils.show(title: "error", message: error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let nicknameVC = NicknameVC.instance(id: appleIDCredential.user, social: "APPLE")
            
            self.navigationController?.pushViewController(nicknameVC, animated: true)
        }
    }
}
