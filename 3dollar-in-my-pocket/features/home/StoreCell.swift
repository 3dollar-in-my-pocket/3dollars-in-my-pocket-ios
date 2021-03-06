import UIKit

class StoreCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreCell.self)"
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 4, height: 4)
    $0.layer.shadowOpacity = 0.08
  }
  
  let categoryImage = UIImageView().then {
    $0.image = UIImage(named: "img_60_bungeoppang")
    $0.contentMode = .scaleAspectFit
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 16)
  }
  
  let categoriesLabel = UILabel().then {
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
    self.backgroundColor = .clear
    self.addSubViews(
      containerView, categoryImage, titleLabel, categoriesLabel,
      distanceImage, distanceLabel, starImage, rankLabel
    )
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.width.equalTo(264)
      make.height.equalTo(104)
      make.bottom.equalToSuperview().offset(-10)
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.centerY.equalTo(self.containerView)
      make.top.equalTo(self.containerView).offset(22)
      make.bottom.equalTo(self.containerView).offset(-22)
      make.width.height.equalTo(60)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.containerView).offset(18)
      make.left.equalTo(self.categoryImage.snp.right).offset(13)
      make.right.equalTo(self.containerView).offset(-16)
    }
    
    self.categoriesLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.titleLabel)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
    }
    
    self.distanceImage.snp.makeConstraints { make in
      make.left.equalTo(self.titleLabel)
      make.bottom.equalTo(self.containerView).offset(-15)
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
      self.containerView.backgroundColor = .black
      self.titleLabel.textColor = .white
      self.categoriesLabel.textColor = .white
      self.distanceLabel.textColor = .white
      self.rankLabel.textColor = .white
    } else {
      self.containerView.backgroundColor = .white
      self.titleLabel.textColor = .black
      self.categoriesLabel.textColor = UIColor(r: 114, g: 114, b: 114)
      self.distanceLabel.textColor = .black
      self.rankLabel.textColor = .black
    }
  }
  
  func bind(store: StoreResponse) {
    self.categoryImage.image = UIImage(named: "img_60_\(store.category.lowcase)")
    
    if store.distance >= 1000 {
      distanceLabel.text = "1km+"
    } else {
      distanceLabel.text = "\(store.distance)m"
    }
    self.titleLabel.text = store.storeName
    
    if floor(store.rating) == store.rating {
      self.rankLabel.text = "\(Int(store.rating))점"
    } else {
      self.rankLabel.text = "\(store.rating)점"
    }
    
    var categories = ""
    for category in store.categories {
      categories.append("#\(category.name) ")
    }
    self.categoriesLabel.text = categories
  }
}
