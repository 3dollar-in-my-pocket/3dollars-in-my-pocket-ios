import UIKit

class QuestionCell: BaseTableViewCell {
  
  static let registerId = "\(QuestionCell.self)"
  
  let titleLabel = UILabel().then {
    $0.text = "FAQ"
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
  }
  
  let arrowImage = UIImageView().then {
    $0.image = UIImage(named: "ic_right_arrow")
  }
  
  
  override func setup() {
    backgroundColor = .clear
    selectionStyle = .none
    addSubViews(titleLabel, arrowImage)
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(32 * RatioUtils.widthRatio)
      make.top.equalToSuperview().offset(13)
      make.bottom.equalToSuperview().offset(-13)
    }
    
    self.arrowImage.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
    }
  }
  
  func bind(title: String) {
    self.titleLabel.text = title
  }
}
