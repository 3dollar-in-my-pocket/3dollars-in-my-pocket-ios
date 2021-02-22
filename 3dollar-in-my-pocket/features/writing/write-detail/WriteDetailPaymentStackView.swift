import UIKit

class WriteDetailPaymentStackView: UIStackView {
  
  let cashCheckButton = UIButton().then {
    $0.setTitle("write_store_payment_cash".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_check_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_check_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let cardCheckButton = UIButton().then {
    $0.setTitle("write_store_payment_card".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_check_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_check_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let transferCheckButton = UIButton().then {
    $0.setTitle("write_store_payment_transfer".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_check_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_check_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func selectPaymentType(paymentTypes: [PaymentType]) {
    self.clearSelect()
    
    for paymentType in paymentTypes {
      let index = paymentType.getIndexValue()
      
      if let button = self.arrangedSubviews[index] as? UIButton {
        button.isSelected = true
      }
    }
  }
  
  private func setup() {
    self.alignment = .leading
    self.axis = .horizontal
    self.backgroundColor = .clear
    self.distribution = .equalSpacing
    self.spacing = 36
    
    self.addArrangedSubview(cashCheckButton)
    self.addArrangedSubview(cardCheckButton)
    self.addArrangedSubview(transferCheckButton)
  }
  
  private func clearSelect() {
    for subView in self.arrangedSubviews {
      if let button = subView as? UIButton {
        button.isSelected = false
      }
    }
  }
}
