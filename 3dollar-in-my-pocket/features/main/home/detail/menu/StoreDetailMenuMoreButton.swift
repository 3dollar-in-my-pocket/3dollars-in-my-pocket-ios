import UIKit

class StoreDetailMenuMoreButton: UIButton {
  
  let dividorView = UIView().then {
    $0.backgroundColor = UIColor(r: 226, g: 226, b: 226)
  }
  
  let moreLabel = UILabel().then {
    $0.text = "store_detail_more".localized
    $0.textColor = UIColor(r: 114, g: 114, b: 114)
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
  }
  
  let moreImage = UIImageView().then {
    $0.image = UIImage(named: "ic_arrow_bottom")
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.bindConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .clear
    addSubViews(dividorView, moreLabel, moreImage)
  }
  
  private func bindConstraints() {
    self.dividorView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.top.equalToSuperview().offset(11)
      make.height.equalTo(1)
    }
    
    self.moreLabel.snp.makeConstraints { make in
      make.top.equalTo(self.dividorView.snp.bottom).offset(14)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-12)
    }
    
    self.moreImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.moreLabel)
      make.left.equalTo(self.moreLabel.snp.right).offset(4)
    }
  }
}
