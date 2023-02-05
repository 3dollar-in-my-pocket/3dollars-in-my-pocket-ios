import UIKit
import RxSwift

class NicknameViewController: BaseVC {
  private let nicknameView = NicknameView()
  private let viewModel: NicknameViewModel
  
  
  init(signinRequest: SigninRequest) {
    self.viewModel = NicknameViewModel(
      signinRequest: signinRequest,
      userDefaults: UserDefaultsUtil(),
      userService: UserService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(signinRequest: SigninRequest) -> NicknameViewController {
    return NicknameViewController(signinRequest: signinRequest)
  }
  
  override func loadView() {
    self.view = self.nicknameView
  }
  
  override func bindViewModel() {
    // Bind input
    self.nicknameView.nicknameField.rx.text.orEmpty
      .bind(to: self.viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    
    self.nicknameView.startButton1.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapStartButton)
      .disposed(by: self.disposeBag)
    
    self.nicknameView.startButton2.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapStartButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    self.viewModel.output.startButtonEnable
      .asDriver(onErrorJustReturn: false)
      .drive(self.nicknameView.rx.isStartButtonEnable)
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.presentPolicy
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
          self?.presentPolicy()
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.errorLabelHidden
      .asDriver(onErrorJustReturn: true)
      .drive(self.nicknameView.rx.isErrorLabelHidden)
      .disposed(by: self.disposeBag)
      
    self.viewModel.showLoading
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { isShow in
          LoadingManager.shared.showLoading(isShow: isShow)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.unknown)
      .drive(onNext: self.showErrorAlert(error:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.showSystemAlert
      .asDriver(onErrorJustReturn: .init())
      .drive(onNext: self.showSystemAlert(alert:))
      .disposed(by: self.disposeBag)
  }
  
  override func bindEvent() {
    self.nicknameView.backButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.popupVC)
      .disposed(by: self.disposeBag)
    
      self.nicknameView.rx.tapBackground
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.nicknameView.hideKeyboard)
      .disposed(by: self.disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
    
    private func presentPolicy() {
        let viewController = PolicyViewController.instance(delegate: self)
        
        self.present(viewController, animated: true)
    }
}

extension NicknameViewController: PolicyViewControllerDelegate {
    func onDismiss() {
        self.goToMain()
    }
}
