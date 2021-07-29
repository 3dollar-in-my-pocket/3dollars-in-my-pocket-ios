import UIKit
import RxSwift
import RxCocoa

class NicknameView: BaseView {
  
  let tapGestureView = UITapGestureRecognizer()
  
  let backButton = UIButton().then {
    $0.setImage(R.image.ic_back_white(), for: .normal)
  }
  
  let bgCloud = UIImageView().then {
    $0.image = R.image.bg_cloud()
    $0.contentMode = .scaleToFill
  }
  
  let nicknameLabel1 = UILabel().then {
    $0.text = R.string.localization.nickname_label_1()
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
    $0.textColor = .white
  }
  
  let nicknameFieldBg = UIView().then {
    $0.layer.cornerRadius = 28
    $0.layer.borderWidth = 2
    $0.layer.borderColor = R.color.pink()?.cgColor
    $0.backgroundColor = .clear
  }
  
  let nicknameField = UITextField().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
    $0.textColor = R.color.pink()
    $0.returnKeyType = .done
    $0.attributedPlaceholder = NSAttributedString(
      string: R.string.localization.nickname_placeholder(),
      attributes: [
        NSAttributedString.Key.foregroundColor: R.color.pink()?.withAlphaComponent(0.3) as Any
      ]
    )
  }
  
  let nicknameLabel2 = UILabel().then {
    $0.text = R.string.localization.nickname_label_2()
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
    $0.textColor = .white
  }
  
  let startButton1 = UIButton().then {
    $0.setTitle(R.string.localization.nickname_label_3(), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
    $0.setTitleColor(.white, for: .disabled)
    $0.setTitleColor(R.color.red(), for: .normal)
    $0.isEnabled = false
  }
  
  let startButton2 = UIButton().then {
    $0.setImage(R.image.img_start_off_disable(), for: .disabled)
    $0.setImage(R.image.img_start_off_normal(), for: .normal)
    $0.backgroundColor = .clear
    $0.isEnabled = false
  }
  
  let warningImage = UIImageView().then {
    $0.image = R.image.ic_warning()
    $0.isHidden = true
  }
  
  let warningLabel = UILabel().then {
    $0.text = R.string.localization.nickname_alreay_existed()
    $0.textColor = R.color.red()
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
    $0.isHidden = true
  }
  
  
  override func setup() {
    self.backgroundColor = R.color.gray100()
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(self.tapGestureView)
    self.nicknameField.delegate = self
    self.addSubViews([
      backButton,
      bgCloud,
      nicknameLabel1,
      nicknameFieldBg,
      nicknameField,
      nicknameLabel2,
      startButton1,
      startButton2,
      warningImage,
      warningLabel
    ])
  }
  
  override func bindConstraints() {
    self.backButton.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(48)
    }
    
    self.bgCloud.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(backButton.snp.bottom).offset(44)
    }
    
    self.nicknameLabel1.snp.makeConstraints { (make) in
      make.left.equalTo(bgCloud.snp.left).offset(24)
      make.top.equalTo(bgCloud.snp.top).offset(161)
    }
    
    self.nicknameFieldBg.snp.makeConstraints { (make) in
      make.left.equalTo(nicknameLabel1.snp.left)
      make.top.equalTo(nicknameLabel1.snp.bottom).offset(16)
      make.height.equalTo(56)
      make.width.equalTo(282)
    }
    
    self.nicknameField.snp.makeConstraints { (make) in
      make.left.equalTo(nicknameFieldBg.snp.left).offset(20)
      make.top.equalTo(nicknameFieldBg.snp.top)
      make.bottom.equalTo(nicknameFieldBg.snp.bottom)
      make.right.equalTo(nicknameFieldBg.snp.right).offset(-20)
    }
    
    self.nicknameLabel2.snp.makeConstraints { (make) in
      make.centerY.equalTo(nicknameFieldBg.snp.centerY)
      make.left.equalTo(nicknameFieldBg.snp.right).offset(14)
    }
    
    self.startButton1.snp.makeConstraints { (make) in
      make.left.equalTo(nicknameLabel1.snp.left)
      make.top.equalTo(nicknameFieldBg.snp.bottom).offset(16)
      make.height.equalTo(38)
    }
    
    self.startButton2.snp.makeConstraints { (make) in
      make.centerY.equalTo(startButton1.snp.centerY)
      make.left.equalTo(startButton1.snp.right).offset(8)
    }
    
    self.warningImage.snp.makeConstraints { (make) in
      make.centerY.equalTo(startButton1)
      make.left.equalTo(startButton2.snp.right).offset(8)
      make.width.height.equalTo(12)
    }
    
    self.warningLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(warningImage)
      make.left.equalTo(warningImage.snp.right).offset(5)
    }
  }
  
  func hideKeyboard() {
    self.nicknameField.resignFirstResponder()
  }
  
  private func showKeyboard() {
    self.nicknameField.becomeFirstResponder()
  }
}

extension NicknameView: UITextFieldDelegate {
  
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
    self.hideKeyboard()
    
    return true
  }
}

extension Reactive where Base: NicknameView {
  
  var startButtonEnable: Binder<Bool> {
    return Binder(self.base) { view, isEnable in
      view.startButton1.isEnabled = isEnable
      view.startButton2.isEnabled = isEnable
    }
  }
  
  var errorLabelHidden: Binder<Bool> {
    return Binder(self.base) { view, isHidden in
      view.warningImage.isHidden = isHidden
      view.warningLabel.isHidden = isHidden
    }
  }
}
