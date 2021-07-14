import UIKit
import RxSwift

class SplashVC: BaseVC {
  
  private let splashView = SplashView()
  private let viewModel = SplashViewModel(
    userDefaults: UserDefaultsUtil(),
    userService: UserService()
  )
  
  
  static func instance() -> SplashVC {
    return SplashVC.init(nibName: nil, bundle: nil)
  }
  
  override func loadView() {
    self.view = self.splashView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.startAnimation()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func bindViewModel() {
    // Bind Output
    self.viewModel.output.goToSignIn
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.goToSignIn)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToMain
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.goToMain)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToSignInWithAlert
      .asDriver(onErrorJustReturn: AlertContent())
      .drive(onNext: self.showGoToSignInAlert(alertContent:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showMaintenanceAlert
      .asDriver(onErrorJustReturn: AlertContent())
      .drive(onNext: self.showMaintenanceAlert(alertContent:))
      .disposed(by: disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.custom(""))
      .drive(onNext: self.showErrorAlert(error:))
      .disposed(by: disposeBag)
  }
  
  private func startAnimation() {
    self.splashView.lottie.play { [weak self] _ in
      UIView.animate(
        withDuration: 0.5,
        animations: { [weak self] in
          self?.splashView.alpha = 0
        }) { _ in
        self?.viewModel.input.viewDidLoad.onNext(())
      }
    }
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
