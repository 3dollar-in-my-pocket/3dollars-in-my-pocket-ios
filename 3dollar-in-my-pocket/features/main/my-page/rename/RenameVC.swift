import UIKit

class RenameVC: BaseVC {
  
  private lazy var renameView = RenameView(frame: self.view.frame)
  var currentName: String!
  
  static func instance(currentName: String) -> RenameVC {
    return RenameVC(nibName: nil, bundle: nil).then {
      $0.currentName = currentName
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = renameView
    setupNickname()
  }
  
  override func bindViewModel() {
    renameView.backBtn.rx.tap.bind {
      self.navigationController?.popViewController(animated: true)
    }.disposed(by: disposeBag)
    
    renameView.nicknameField.rx.text.orEmpty
      .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
      .bind(onNext: self.renameView.setBtnEnable(isEnable:))
      .disposed(by: disposeBag)
    
    renameView.tapGestureView.rx.event.bind { (recognizer) in
      self.renameView.nicknameField.resignFirstResponder()
    }.disposed(by: disposeBag)
    
    renameView.startBtn1.rx.tap
      .bind(onNext: self.changeNickname)
      .disposed(by: disposeBag)
    
    renameView.startBtn2.rx.tap
      .bind(onNext: self.changeNickname)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func setupNickname() {
    renameView.oldNicknameLabel.text = currentName
    renameView.nicknameField.delegate = self
  }
  
  private func changeNickname() {
    let nickname = renameView.nicknameField.text!
    
    self.renameView.showLoading(isShow: true)
    UserService().changeNickname(nickname: nickname)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          self.renameView.showLoading(isShow: false)
          self.navigationController?.popViewController(animated: true)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let error = error as? HTTPError {
            if error == HTTPError.badRequest {
              self.renameView.existedSameName()
            } else {
              self.showHTTPErrorAlert(error: error)
            }
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.showSystemAlert(alert: alertContent)
          }
          self.renameView.showLoading(isShow: false)
        })
      .disposed(by: disposeBag)
  }
}

extension RenameVC: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textFieldText = textField.text,
          let rangeOfTextToReplace = Range(range, in: textFieldText) else {
      return false
    }
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    
    return count <= 8
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    return true;
  }
}

