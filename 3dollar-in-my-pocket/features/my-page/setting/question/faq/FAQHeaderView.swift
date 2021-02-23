import UIKit

class FAQHeaderView: BaseView {
  
  let underlineView = UIView().then {
    $0.backgroundColor = UIColor(r: 238, g: 98, b: 76)
    $0.alpha = 0.5
  }
  
  let titleLabel = UILabel().then {
    $0.text = "제목"
    $0.textColor = .white
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 16)
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(underlineView, titleLabel)
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
      make.bottom.equalToSuperview().offset(-8)
    }
    
    self.underlineView.snp.makeConstraints { make in
      make.left.right.equalTo(self.titleLabel)
      make.bottom.equalTo(self.titleLabel).offset(-8)
      make.height.equalTo(8)
    }
  }
  
  func bind(title: String) {
    self.titleLabel.text = title
  }
}
