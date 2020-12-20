import UIKit
import RxSwift

class SplashVC: BaseVC {
  
  private lazy var splashView = SplashView(frame: self.view.frame)
  private let viewModel = SplashViewModel(
    userDefaults: UserDefaultsUtil(),
    userService: UserService()
  )
  
  
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
    
    self.viewModel.output.showGoToSignInAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showGoToSignInAlert(alertContent:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showMaintenanceAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showMaintenanceAlert(alertContent:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
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
  
  private func showGoToSignInAlert(alertContent: AlertContent) {
    AlertUtils.showWithAction(
      controller: self,
      title: alertContent.title,
      message: alertContent.message
    ) {
      self.goToSignIn()
    }
  }
  
  private func showMaintenanceAlert(alertContent: AlertContent) {
    AlertUtils.showWithAction(
      controller: self,
      title: alertContent.title,
      message: alertContent.message) {
      UIControl().sendAction(
        #selector(URLSessionTask.suspend),
        to: UIApplication.shared,
        for: nil
      )
    }
  }
}
