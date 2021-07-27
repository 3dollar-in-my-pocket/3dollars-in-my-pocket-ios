import UIKit
import RxSwift

class SignInVC: BaseVC {
  
  private let signInView = SignInView()
  private let viewModel = SignInViewModel(
    userDefaults: UserDefaultsUtil(),
    userService: UserService(),
    kakaoManager: KakaoSigninManager(),
    appleManager: AppleSigninManager()
  )
  
  static func instance() -> UINavigationController {
    let controller = SignInVC(nibName: nil, bundle: nil)
    
    return UINavigationController(rootViewController: controller)
  }
  
  override func loadView() {
    self.view = self.signInView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.signInView.startFadeIn()
    self.navigationController?.isNavigationBarHidden = true
    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  override func bindViewModel() {
    // Bind input
    self.signInView.kakaoButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapKakaoButton)
      .disposed(by: self.disposeBag)
    
    self.signInView.appleButton.rx
      .controlEvent(.touchUpInside)
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .map { _ in Void() }
      .bind(to: self.viewModel.input.tapAppleButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    self.viewModel.output.goToMain
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.goToMain)
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.goToNickname
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.goToNickname)
      .disposed(by: self.disposeBag)
    
    self.viewModel.showSystemAlert
      .asDriver(onErrorJustReturn: AlertContent(title: nil, message: ""))
      .drive(onNext: self.showSystemAlert(alert:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.unknown)
      .drive(onNext: self.showErrorAlert(error:))
      .disposed(by: self.disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
  
  private func goToNickname() {
    let nicknameVC = NicknameVC.instance(id: 0, token: "")
    
    self.navigationController?.pushViewController(nicknameVC, animated: true)
  }
}
