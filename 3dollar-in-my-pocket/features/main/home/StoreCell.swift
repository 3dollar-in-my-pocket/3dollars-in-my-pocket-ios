import UIKit

class StoreCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreCell.self)"
  
  let categoryImage = UIImageView().then {
    $0.image = UIImage(named: "img_60_bungeoppang")
    $0.contentMode = .scaleAspectFit
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-ExtraBold", size: 16)
  }
  
  let descriptionLabel = UILabel().then {
    $0.text = "#붕어빵 #땅콩과자 #호떡"
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
    $0.textColor = UIColor(r: 114, g: 114, b: 114)
  }
  
  let distanceImage = UIImageView().then {
    $0.image = UIImage(named: "ic_near_filled")
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let starImage = UIImageView().then {
    $0.image = UIImage(named: "ic_star")
  }
  
  let rankLabel = UILabel().then {
    $0.textColor = UIColor(r: 200, g: 200, b: 200)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
    $0.textColor = .black
  }
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.setSelected(isSelected: false)
  }
  
  override func setup() {
    self.layer.cornerRadius = 16
    self.backgroundColor = .white
    self.addSubViews(
      categoryImage, titleLabel, descriptionLabel, distanceImage,
      distanceLabel, starImage, rankLabel
    )
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
      make.top.equalToSuperview().offset(22)
      make.bottom.equalToSuperview().offset(-22)
      make.width.height.equalTo(60)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(18)
      make.left.equalTo(self.categoryImage.snp.right).offset(13)
      make.right.equalToSuperview().offset(-16)
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.titleLabel)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
    }
    
    self.distanceImage.snp.makeConstraints { make in
      make.left.equalTo(self.titleLabel)
      make.bottom.equalToSuperview().offset(-15)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.left.equalTo(self.distanceImage.snp.right).offset(4)
      make.centerY.equalTo(self.distanceImage)
    }
    
    self.starImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.distanceImage)
      make.left.equalTo(self.distanceLabel.snp.right).offset(12)
    }
    
    self.rankLabel.snp.makeConstraints { make in
      make.left.equalTo(self.starImage.snp.right).offset(4)
      make.centerY.equalTo(self.distanceLabel)
    }
  }
  
  func setSelected(isSelected: Bool) {
    if isSelected {
      self.backgroundColor = .black
      self.titleLabel.textColor = .white
      self.descriptionLabel.textColor = .white
      self.distanceLabel.textColor = .white
      self.rankLabel.textColor = .white
    } else {
      self.backgroundColor = .white
      self.titleLabel.textColor = .black
      self.descriptionLabel.textColor = UIColor(r: 114, g: 114, b: 114)
      self.distanceLabel.textColor = .black
      self.rankLabel.textColor = .black
    }
  }
  
  func bind(storeCard: StoreCard) {
    switch storeCard.category {
    case .BUNGEOPPANG:
      self.categoryImage.image = UIImage(named: "img_60_bungeoppang")
    case .GYERANPPANG:
      self.categoryImage.image = UIImage(named: "img_60_gyeranppang")
    case .HOTTEOK:
      self.categoryImage.image = UIImage(named: "img_60_hotteok")
    case .TAKOYAKI:
      self.categoryImage.image = UIImage(named: "img_60_takoyaki")
    }
    
    if storeCard.distance >= 1000 {
      distanceLabel.text = "1km+"
    } else {
      distanceLabel.text = "\(storeCard.distance)m"
    }
    self.titleLabel.text = storeCard.storeName
    self.rankLabel.text = "\(storeCard.rating)점"
  }
}
