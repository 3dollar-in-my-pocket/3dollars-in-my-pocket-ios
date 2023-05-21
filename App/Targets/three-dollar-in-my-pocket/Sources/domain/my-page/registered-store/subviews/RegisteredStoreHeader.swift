import UIKit

class RegisteredStoreHeader: BaseView {
  
  let countLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
    $0.textColor = .white
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(countLabel)
  }
  
  override func bindConstraints() {
    self.countLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(12)
      make.bottom.equalToSuperview().offset(-16)
    }
  }
  
  func setCount(count: Int) {
    countLabel.text = String(format: "registered_store_count_format".localized, count)
  }
}
