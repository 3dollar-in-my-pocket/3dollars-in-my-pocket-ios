import UIKit

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
    nicknameView.backBtn.rx.tap.bind {
      self.navigationController?.popViewController(animated: true)
    }.disposed(by: disposeBag)
    
    nicknameView.nicknameField.rx.text.bind { (text) in
      guard let text = text else {return}
      
      self.nicknameView.setBtnEnable(isEnable: !text.isEmpty)
    }.disposed(by: disposeBag)
    
    nicknameView.tapGestureView.rx.event.bind { (recognizer) in
      self.nicknameView.nicknameField.resignFirstResponder()
    }.disposed(by: disposeBag)
    
    nicknameView.startBtn1.rx.tap.bind {
//      self.setNickname()
    }.disposed(by: disposeBag)
    
    nicknameView.startBtn2.rx.tap.bind {
//      self.setNickname()
    }.disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    // Bind Event
    self.nicknameView.nicknameField.rx.text.orEmpty
      .bind(to: self.viewModel.input.nickname)
      .disposed(by: disposeBag)
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func initilizeTextField() {
    self.nicknameView.nicknameField.delegate = self
  }
  
  private func goToMain() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToMain()
    }
  }
  
//  private func setNickname() {
//    let nickname = nicknameView.nicknameField.text!
//
//    UserService.setNickname(nickname: nickname, id: self.id, token: self.token, completion: { [weak self] (response) in
//      switch response.result {
//      case .success(_):
//        if let vc = self {
//          UserDefaultsUtil.setUserToken(token: vc.token)
//          UserDefaultsUtil.setUserId(id: vc.id)
//        }
//        self?.goToMain()
//      case .failure(_):
//        self?.nicknameView.existedSameName()
//      }
//    })
//  }
}

extension NicknameVC: UITextFieldDelegate {
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
