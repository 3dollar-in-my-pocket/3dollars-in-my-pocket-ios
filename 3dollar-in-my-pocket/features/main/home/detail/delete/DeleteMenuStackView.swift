import UIKit

class DeleteMenuStackView: UIStackView {
  
  let notExistedButton = DeleteMenuButton().then {
    $0.setTitle("store_delete_menu_not_existed".localized, for: .normal)
  }
  
  let wronglocationButton = DeleteMenuButton().then {
    $0.setTitle("store_delete_menu_wrong_location".localized, for: .normal)
  }
  
  let overlapButton = DeleteMenuButton().then {
    $0.setTitle("store_delete_menu_overlap".localized, for: .normal)
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.bindConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func select(deleteReason: DeleteReason) {
    self.clearSelected()
    switch deleteReason {
    case .NOSTORE:
      self.notExistedButton.isSelected = true
    case .WRONGNOPOSITION:
      self.wronglocationButton.isSelected = true
    case .OVERLAPSTORE:
      self.overlapButton.isSelected = true
    }
  }
  
  private func setup() {
    self.alignment = .top
    self.axis = .vertical
    self.backgroundColor = .clear
    self.spacing = 10
    self.distribution = .equalSpacing
    
    self.addArrangedSubview(notExistedButton)
    self.addArrangedSubview(wronglocationButton)
    self.addArrangedSubview(overlapButton)
  }
  
  private func bindConstraints() {
    self.notExistedButton.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.left.right.equalToSuperview()
    }
    
    self.wronglocationButton.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.left.right.equalToSuperview()
    }
    
    self.overlapButton.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.left.right.equalToSuperview()
    }
  }
  
  private func clearSelected() {
    self.arrangedSubviews.forEach { view in
      if let button = view as? UIButton {
        button.isSelected = false
      }
    }
  }
}
