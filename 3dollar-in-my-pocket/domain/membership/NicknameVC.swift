import UIKit
import RxSwift

class NicknameVC: BaseVC {
  
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
  
  static func instance(signinRequest: SigninRequest) -> NicknameVC {
    return NicknameVC.init(signinRequest: signinRequest)
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
      .drive(self.nicknameView.rx.startButtonEnable)
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.goToMain
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.goToMain)
      .disposed(by: disposeBag)
    
    self.viewModel.output.errorLabelHidden
      .asDriver(onErrorJustReturn: true)
      .drive(self.nicknameView.rx.errorLabelHidden)
      .disposed(by: self.disposeBag)
      
    self.viewModel.showLoading
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: self.nicknameView.showLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.unknown)
      .drive(onNext: self.showErrorAlert(error:))
      .disposed(by: self.disposeBag)
  }
  
  override func bindEvent() {
    self.nicknameView.backButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .nickname_initialize_page)
      })
      .drive(onNext: self.popupVC)
      .disposed(by: disposeBag)
    
    self.nicknameView.tapGestureView.rx.event
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .map { _ in Void() }
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: self.nicknameView.hideKeyboard)
      .disposed(by:disposeBag)
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
}
