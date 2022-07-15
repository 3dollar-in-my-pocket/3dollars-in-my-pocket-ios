import UIKit

import Base
import RxSwift

class MenuCell: BaseTableViewCell {
  
  static let registerId = "\(MenuCell.self)"
  
  let nameField = UITextField().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
    $0.layer.borderWidth = 1
    $0.placeholder = "ex)슈크림"
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = UIColor(r: 28, g: 28, b: 28)
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
    $0.leftViewMode = .always
    $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
    $0.rightViewMode = .always
    $0.returnKeyType = .done
  }
  
  let descField = UITextField().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
    $0.layer.borderWidth = 1
    $0.placeholder = "ex)3개 2천원"
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = UIColor(r: 28, g: 28, b: 28)
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
    $0.leftViewMode = .always
    $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
    $0.rightViewMode = .always
    $0.returnKeyType = .done
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.disposeBag = DisposeBag()
    self.nameField.text = nil
    self.descField.text = nil
    self.setup()
  }
  
  override func setup() {
    backgroundColor = .clear
    selectionStyle = .none
    self.contentView.addSubViews(nameField, descField)
    
    self.nameField.rx.text.orEmpty
      .map { $0.isEmpty }
      .bind(onNext: self.setNameFieldBorderColor(isEmpty:))
      .disposed(by: disposeBag)
    
    self.descField.rx.text.orEmpty
      .map { $0.isEmpty }
      .bind(onNext: self.setDescFieldBorderColor(isEmpty:))
      .disposed(by: disposeBag)
    
    self.nameField.delegate = self
    self.descField.delegate = self
  }
  
  override func bindConstraints() {
    nameField.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(8)
      make.bottom.equalToSuperview().offset(-8)
      make.height.equalTo(50)
      make.width.equalTo(106)
    }
    
    descField.snp.makeConstraints { (make) in
      make.left.equalTo(nameField.snp.right).offset(8)
      make.centerY.equalTo(nameField.snp.centerY)
      make.height.equalTo(nameField.snp.height)
      make.right.equalToSuperview().offset(-23)
    }
  }
  
  func setMenu(menu: Menu?) {
    if let menu = menu {
      self.nameField.text = menu.name
      self.setNameFieldBorderColor(isEmpty: menu.name.isEmpty ?? true)
      self.descField.text = menu.price
      self.setDescFieldBorderColor(isEmpty: menu.price.isEmpty ?? true)
    }
  }
  
  private func setNameFieldBorderColor(isEmpty: Bool) {
    if isEmpty {
      self.nameField.layer.borderColor = UIColor.init(r: 208, g: 208, b: 208).cgColor
    } else {
      self.nameField.layer.borderColor = UIColor.init(r: 255, g: 161, b: 170).cgColor
    }
  }
  
  private func setDescFieldBorderColor(isEmpty: Bool) {
    if isEmpty {
      self.descField.layer.borderColor = UIColor.init(r: 208, g: 208, b: 208).cgColor
    } else {
      self.descField.layer.borderColor = UIColor.init(r: 255, g: 161, b: 170).cgColor
    }
  }
}

extension MenuCell: UITextFieldDelegate {
  
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
    return count <= 10
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
}


