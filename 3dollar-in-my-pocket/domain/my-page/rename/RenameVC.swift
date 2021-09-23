import UIKit
import RxSwift

class RenameVC: BaseVC {
  
  private let renameView = RenameView()
  private let viewModel = RenameViewModel(userService: UserService())
  var currentName: String!
  
  static func instance(currentName: String) -> RenameVC {
    return RenameVC(name: currentName).then {
      $0.currentName = currentName
    }
  }
  
  init(name: String) {
    self.currentName = name
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = self.renameView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupNickname()
  }
  
  override func bindEvent() {
    self.renameView.backButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    self.renameView.tapGestureView.rx.event
      .asDriver()
      .drive(onNext: { [weak self] _ in
        self?.renameView.endEditing(true)
      })
      .disposed(by: disposeBag)
  }
  
  override func bindViewModel() {
    // Bind input
    self.renameView.nicknameField.rx.text.orEmpty
      .bind(to: self.viewModel.input.newNickname)
      .disposed(by: self.disposeBag)
    
    self.renameView.startBtn1.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapRenameButton)
      .disposed(by: self.disposeBag)
    
    self.renameView.startBtn2.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapRenameButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.isEnableRenameButton
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: self.renameView.setBtnEnable(isEnable:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.isHiddenAlreadyExistedNickname
      .asDriver(onErrorJustReturn: true)
      .drive(onNext: self.renameView.existedSameName(isHidden:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.popViewController
      .asDriver(onErrorJustReturn: ())
      .drive { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.showLoading
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: self.renameView.showLoading(isShow:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: CommonError.init(desc: ""))
      .drive(onNext: self.showErrorAlert(error:))
      .disposed(by: self.disposeBag)
    
    self.viewModel.showSystemAlert
      .asDriver(onErrorJustReturn: .init())
      .drive(onNext: self.showSystemAlert(alert:))
      .disposed(by: self.disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func setupNickname() {
    self.renameView.oldNicknameLabel.text = currentName
    self.renameView.nicknameField.delegate = self
  }
}

extension RenameVC: UITextFieldDelegate {
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    guard let textFieldText = textField.text,
          let rangeOfTextToReplace = Range(range, in: textFieldText) else {
      return false
    }
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    
    return count <= 8
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
