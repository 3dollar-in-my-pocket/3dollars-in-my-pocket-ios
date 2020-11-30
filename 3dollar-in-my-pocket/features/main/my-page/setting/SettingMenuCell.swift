import UIKit

class SettingMenuCell: BaseTableViewCell {
  
  static let registerId = "\(SettingMenuCell.self)"
  
  let iconImageView = UIImageView()
  
  let titleLabel = UILabel().then {
    $0.text = "setting_menu_question".localized
    $0.textColor = .white
    $0.font = UIFont(name: "SpoqaHanSans-Regular", size: 16)
  }
  
  let rightArrow = UIImageView().then {
    $0.image = UIImage(named: "ic_right_arrow")
  }
  
  
  override func setup() {
    backgroundColor = .clear
    selectionStyle = .none
    addSubViews(iconImageView, titleLabel, rightArrow)
  }
  
  override func bindConstraints() {
    self.iconImageView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.top.equalToSuperview().offset(12.5)
      make.bottom.equalToSuperview().offset(-12.5)
      make.width.height.equalTo(16)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.iconImageView)
      make.left.equalTo(self.iconImageView.snp.right).offset(8)
    }
    
    self.rightArrow.snp.makeConstraints { make in
      make.centerY.equalTo(self.iconImageView.snp.centerY)
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
    }
  }
  
  func bind(image: UIImage, title: String) {
    self.iconImageView.image = image
    self.titleLabel.text = title
  }
}
