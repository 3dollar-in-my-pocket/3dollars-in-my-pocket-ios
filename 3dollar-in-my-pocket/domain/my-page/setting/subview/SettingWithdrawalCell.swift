import UIKit

import Base

class SettingWithdrawalCell: BaseTableViewCell {
  
  static let registerId = "\(SettingWithdrawalCell.self)"
  
  let warningImage = UIImageView().then {
    $0.image = UIImage(named: "ic_warning_white")
  }
  
  let withdrawalLabel = UILabel().then {
    $0.text = "setting_withdrawal".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
    $0.textColor = UIColor(r: 153, g: 153, b: 153)
  }
  
  override func setup() {
    backgroundColor = .clear
    selectionStyle = .none
    addSubViews(warningImage, withdrawalLabel)
  }
  
  override func bindConstraints() {
    warningImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.top.equalToSuperview().offset(8)
      make.bottom.equalToSuperview().offset(-8)
      make.width.height.equalTo(16)
    }
    
    withdrawalLabel.snp.makeConstraints { make in
      make.left.equalTo(self.warningImage.snp.right).offset(8)
      make.centerY.equalTo(self.warningImage)
    }
  }
}
