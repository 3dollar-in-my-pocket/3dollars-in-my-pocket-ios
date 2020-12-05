import UIKit
import RxSwift

class SplashVC: BaseVC {
  
  private lazy var splashView = SplashView(frame: self.view.frame)
  private let viewModel = SplashViewModel(userDefaults: UserDefaultsUtil())
  
  
  static func instance() -> SplashVC {
    return SplashVC.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = splashView
    
    splashView.lottie.play { [weak self] (isFinish) in
      if isFinish {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
          self?.splashView.alpha = 0
        }) { _ in
          self?.viewModel.validateUserToken()
        }
      }
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func bindViewModel() {
    // Bind Output
    self.viewModel.output.goToMain
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToMain)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToSignIn
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToSignIn)
      .disposed(by: disposeBag)
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
  
  private func goToSignIn() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToSignIn()
    }
  }
}
