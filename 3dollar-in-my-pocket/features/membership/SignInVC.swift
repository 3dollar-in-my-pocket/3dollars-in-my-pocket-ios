import UIKit
import RxSwift
import AuthenticationServices

class SignInVC: BaseVC {
  
  private lazy var signInView = SignInView(frame: self.view.frame)
  private let viewModel = SignInViewModel(
    userDefaults: UserDefaultsUtil(),
    userService: UserService()
  )
  
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
    // Bind input
    signInView.kakaoBtn.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapKakao)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.goToMain
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToMain)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToNickname
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToNickname)
      .disposed(by: disposeBag)
    
    self.viewModel.output.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    signInView.appleBtn.rx
      .controlEvent(.touchUpInside)
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(onNext: requestAppleSignIn)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func requestAppleSignIn() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    
    request.requestedScopes = [.fullName, .email]
    
    let authController = ASAuthorizationController(authorizationRequests: [request])
    
    authController.delegate = self
    authController.performRequests()
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
  
  private func goToNickname(id: Int, token: String) {
    let nicknameVC = NicknameVC.instance(id: id, token: token)
    
    self.navigationController?.pushViewController(nicknameVC, animated: true)
  }
}

extension SignInVC: ASAuthorizationControllerDelegate {
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    if (error as NSError).code != 1001 { // 사용자가 직접 취소
      let alertContent = AlertContent(
        title: "Sign with apple error",
        message: error.localizedDescription
      )
      
      self.showSystemAlert(alert: alertContent)
    }
  }
  
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      self.viewModel.input.signWithApple.onNext(appleIDCredential.user)
    }
  }
}
