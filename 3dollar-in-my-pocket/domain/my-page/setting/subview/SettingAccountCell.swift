import UIKit

import Base

class SettingAccountCell: BaseTableViewCell {
  
  static let registerId = "\(SettingAccountCell.self)"
  
  let topLineView = UIView().then {
    $0.backgroundColor = UIColor(r: 43, g: 43, b: 43)
  }
  
  let snsIconImage = UIImageView()
  
  let accountTypeLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let signOutButton = UIButton().then {
    $0.setTitle("setting_sign_out".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 238, g: 98, b: 76), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
  }
  
  
  override func setup() {
    backgroundColor = .clear
    selectionStyle = .none
    addSubViews(topLineView, snsIconImage, accountTypeLabel, signOutButton)
  }
  
  override func bindConstraints() {
    self.topLineView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
      make.height.equalTo(1)
      make.top.equalToSuperview().offset(12.5)
    }
    
    self.snsIconImage.snp.makeConstraints { make in
      make.left.equalTo(self.topLineView)
      make.top.equalTo(self.topLineView.snp.bottom).offset(16)
      make.width.height.equalTo(16)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    self.accountTypeLabel.snp.makeConstraints { make in
      make.left.equalTo(self.snsIconImage.snp.right).offset(8)
      make.centerY.equalTo(self.snsIconImage)
    }
    
    self.signOutButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.snsIconImage)
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
    }
  }
  
  func bind(socialType: SocialType) {
    switch socialType {
    case .apple:
      self.snsIconImage.image = R.image.ic_setting_apple()
      self.accountTypeLabel.text = "애플 계정 회원"
    case .kakao, .google:
      self.snsIconImage.image = R.image.ic_setting_kakao()
      self.accountTypeLabel.text = "카카오 계정 회원"
        
    default:
        break
    }
  }
}
