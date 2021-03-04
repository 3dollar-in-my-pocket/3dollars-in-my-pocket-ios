import UIKit

class HomeEmptyStoreCell: BaseView {
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.08
  }
  
  let emptyImage = UIImageView().then {
    $0.image = UIImage(named: "img_empty_home")
  }
  
  let emptyTitleLabel = UILabel().then {
    $0.text = "home_empty_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 16)
    $0.textColor = .black
    $0.setKern(kern: -0.96)
  }
  
  let emptyDescriptionLabel = UILabel().then {
    $0.text = "home_empty_description".localized
    $0.textColor = UIColor(r: 114, g: 114, b: 114)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
    $0.setKern(kern: -0.72)
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(containerView, emptyImage, emptyTitleLabel, emptyDescriptionLabel)
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview()
      make.top.equalTo(self.emptyImage).offset(-12)
    }
    
    self.emptyImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().offset(-12)
      make.width.height.equalTo(80)
    }
    
    self.emptyTitleLabel.snp.makeConstraints { make in
      make.left.equalTo(self.emptyImage.snp.right).offset(16)
      make.top.equalTo(self.containerView).offset(32)
    }
    
    self.emptyDescriptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.emptyTitleLabel)
      make.top.equalTo(self.emptyTitleLabel.snp.bottom).offset(8)
    }
  }
}
