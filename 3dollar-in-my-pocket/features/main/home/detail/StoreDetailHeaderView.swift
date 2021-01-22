import UIKit

class StoreDetailHeaderView: BaseView {
  
  let titleLabel = UILabel().then {
    $0.text = "헤더 이름"
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
  }
  
  let rightButton = UIButton().then {
    $0.setTitle("버튼 제목", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = UIFont(name: "SpoqaHanSans-Bold", size: 12)
    $0.layer.cornerRadius = 15
    $0.backgroundColor = UIColor(r: 255, g: 92, b: 67)
    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(titleLabel, rightButton)
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(40)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.titleLabel)
      make.height.equalTo(30)
      make.bottom.equalToSuperview()
    }
  }
}
