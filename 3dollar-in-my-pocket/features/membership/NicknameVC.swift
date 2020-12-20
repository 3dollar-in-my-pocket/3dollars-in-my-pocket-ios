import UIKit
import RxSwift

class NicknameVC: BaseVC {
  
  private lazy var nicknameView = NicknameView(frame: self.view.frame)
  private let viewModel: NicknameViewModel
  
  
  init(id: Int, token: String) {
    self.viewModel = NicknameViewModel(
      id: id,
      token: token,
      userDefaults: UserDefaultsUtil(),
      userService: UserService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("")
  }
  
  static func instance(id: Int, token: String) -> NicknameVC {
    return NicknameVC.init(id: id, token: token)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = nicknameView
    self.initilizeTextField()
  }
  
  override func bindViewModel() {
    // Bind input
    self.nicknameView.nicknameField.rx.text.orEmpty
      .bind(to: self.viewModel.input.nickname)
      .disposed(by: disposeBag)
    
    self.nicknameView.startBtn1.rx.tap
      .bind(to: self.viewModel.input.tapStartButton)
      .disposed(by: disposeBag)
    
    self.nicknameView.startBtn2.rx.tap
      .bind(to: self.viewModel.input.tapStartButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.nicknameView.showLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.setButtonEnable
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.nicknameView.setButtonEnable(isEnable:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToMain
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToMain)
      .disposed(by: disposeBag)
    
    self.viewModel.output.errorLabel
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.nicknameView.setErrorMessage(message:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.nicknameView.backBtn.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popupVC)
      .disposed(by: disposeBag)
    
    self.nicknameView.tapGestureView.rx.event
      .observeOn(MainScheduler.instance)
      .map { _ in Void() }
      .bind(onNext: self.nicknameView.hideKeyboard)
      .disposed(by:disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func initilizeTextField() {
    self.nicknameView.nicknameField.delegate = self
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
}

extension NicknameVC: UITextFieldDelegate {
  func textField(
    _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textFieldText = textField.text,
          let rangeOfTextToReplace = Range(range, in: textFieldText) else {
      return false
    }
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    
    return count <= 8
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.nicknameView.hideKeyboard()
    return true
  }
}
