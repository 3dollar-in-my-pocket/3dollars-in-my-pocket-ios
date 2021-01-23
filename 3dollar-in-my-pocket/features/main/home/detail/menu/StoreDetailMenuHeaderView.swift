import UIKit

class StoreDetailMenuHeaderView: BaseView {
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  let menuLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.text = "store_detail_menu".localized
  }
  
  let menuValueLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
    $0.text = "store_detail_menu_format".localized
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(containerView, menuLabel, menuValueLabel)
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(12)
      make.bottom.equalTo(self.menuLabel).offset(3)
      make.bottom.equalToSuperview()
    }
    
    self.menuLabel.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.top.equalTo(self.containerView).offset(24)
    }
    
    self.menuValueLabel.snp.makeConstraints { make in
      make.left.equalTo(self.menuLabel.snp.right).offset(5)
      make.centerY.equalTo(self.menuLabel)
    }
  }
}
