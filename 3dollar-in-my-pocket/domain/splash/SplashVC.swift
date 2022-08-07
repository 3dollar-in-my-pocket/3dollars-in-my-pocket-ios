import UIKit
import RxSwift

class SplashVC: BaseVC {
  
  private let splashView = SplashView()
  private let viewModel = SplashViewModel(
    userDefaults: UserDefaultsUtil(),
    userService: UserService(),
    remoteConfigService: RemoteConfigService(),
    metaContext: MetaContext.shared,
    medalService: MedalService(),
    feedbackService: FeedbackService()
  )
  
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  static func instance() -> SplashVC {
    return SplashVC.init(nibName: nil, bundle: nil)
  }
  
  override func loadView() {
    self.view = self.splashView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.willEnterForegroundNotification(_:)),
      name: UIScene.willEnterForegroundNotification,
      object: nil)
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
    
    self.viewModel.output.showUpdateAlert
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.showUpdateAlert)
      .disposed(by: self.disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.custom(""))
      .drive(onNext: self.showErrorAlert(error:))
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
  
  private func showUpdateAlert() {
    AlertUtils.showWithAction(
      title: R.string.localization.splash_need_update_title(),
      message: R.string.localization.splash_need_update_description()
    ) { _ in
      if let url = URL(string: "itms-apps://itunes.apple.com/app/1496099467"),
         UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
  }
  
  @objc private func willEnterForegroundNotification(_ notification: Notification) {
    self.splashView.startAnimation { [weak self] in
      self?.viewModel.input.viewDidLoad.onNext(())
    }
  }
}
