import UIKit

class WriteDetailTypeStackView: UIStackView {
  
  let roadRadioButton = UIButton().then {
    $0.setTitle("write_store_type_road".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_radio_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_radio_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let storeRadioButton = UIButton().then {
    $0.setTitle("write_store_type_store".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_radio_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_radio_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let convenienceStoreRadioButton = UIButton().then {
    $0.setTitle("write_store_type_convenience_store".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_radio_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_radio_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }

  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setup()
    self.bindConstraints()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.alignment = .leading
    self.axis = .horizontal
    self.backgroundColor = .clear
    self.distribution = .equalSpacing
    self.spacing = 31
    
    self.addArrangedSubview(roadRadioButton)
    self.addArrangedSubview(storeRadioButton)
    self.addArrangedSubview(convenienceStoreRadioButton)
  }
  
  func selectType(type: StoreType?) {
    self.clearSelect()
    
    if let type = type {
      let index = type.getIndexValue()
      
      if let button = self.arrangedSubviews[index] as? UIButton {
        button.isSelected = true
      }
    }
  }
  
  private func bindConstraints() {
    self.roadRadioButton.snp.makeConstraints { make in
      make.height.equalTo(20)
    }
    
    self.storeRadioButton.snp.makeConstraints { make in
      make.height.equalTo(20)
    }
    
    self.convenienceStoreRadioButton.snp.makeConstraints { make in
      make.height.equalTo(20)
    }
  }
  
  private func clearSelect() {
    for subView in self.arrangedSubviews {
      if let button = subView as? UIButton {
        button.isSelected = false
      }
    }
  }
}
