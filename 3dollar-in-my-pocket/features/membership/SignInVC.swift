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
    
    signInView.startFadeIn()
    navigationController?.isNavigationBarHidden = true
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  override func bindViewModel() {
    signInView.kakaoBtn.rx.tap
      .bind(onNext: requestKakaoSignIn)
      .disposed(by: disposeBag)
    
    signInView.appleBtn.rx
      .controlEvent(.touchUpInside)
      .bind(onNext: requestAppleSignIn)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func requestKakaoSignIn() {
    guard let kakaoSession = KOSession.shared() else {
      AlertUtils.show(message: "Kakao session is null")
      return
    }
    
    if kakaoSession.isOpen() {
      kakaoSession.close()
    }
    
    kakaoSession.open { [weak self] (error) in
      if let error = error {
        if (error as NSError).code != 2 {
          AlertUtils.show(title: "error", message: error.localizedDescription)
        }
      } else {
        KOSessionTask.userMeTask { (error, me) in
          if let userId = me?.id,
             let vc = self {
            vc.signIn(socialId: userId, socialType: "KAKAO")
          }
        }
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
  
  private func signIn(socialId: String, socialType: String) {
    let user = User.init(socialId: socialId, socialType: socialType)
    
    UserService.signIn(user: user) { [weak self] (response) in
      switch response.result {
      case .success(let signIn):
        if signIn.state {
          UserDefaultsUtil.setUserToken(token: signIn.token)
          UserDefaultsUtil.setUserId(id: signIn.id)
          self?.goToMain()
        } else {
          let nicknameVC = NicknameVC.instance(id: signIn.id, token: signIn.token)
          
          self?.navigationController?.pushViewController(nicknameVC, animated: true)
        }
      case.failure(let error):
        AlertUtils.show(title: "SignIn error", message: error.localizedDescription)
      }
    }
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
}
extension SignInVC: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    if (error as NSError).code != 1001 { // 사용자가 직접 취소
      AlertUtils.show(title: "error", message: error.localizedDescription)
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      self.signIn(socialId: appleIDCredential.user, socialType: "APPLE")
    }
  }
}
