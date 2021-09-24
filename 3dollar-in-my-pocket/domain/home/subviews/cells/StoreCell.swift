import UIKit

class StoreCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreCell.self)"
  static let itemSize: CGSize = .init(width: 264, height: 114)
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 4, height: 4)
    $0.layer.shadowOpacity = 0.08
  }
  
  let categoryImage = UIImageView().then {
    $0.image = R.image.img_60_bungeoppang()
    $0.contentMode = .scaleAspectFit
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = R.font.appleSDGothicNeoEB00(size: 14)
  }
  
  let categoriesLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
    $0.textColor = R.color.gray60()
  }
  
  let distanceImage = UIImageView().then {
    $0.image = R.image.ic_near_filled()
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = R.color.gray90()
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let starImage = UIImageView().then {
    $0.image = R.image.ic_star()
  }
  
  let rankLabel = UILabel().then {
    $0.textColor = R.color.gray90()
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.setSelected(isSelected: false)
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(
      containerView,
      categoryImage,
      titleLabel,
      categoriesLabel,
      distanceImage,
      distanceLabel,
      starImage,
      rankLabel
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
      self.categoriesLabel.textColor = R.color.gray60()
      self.distanceLabel.textColor = R.color.gray90()
      self.rankLabel.textColor = R.color.gray90()
    }
  }
  
  func bind(store: StoreInfoResponse) {
    self.categoryImage.image = UIImage(named: "img_60_\(store.categories[0].lowcase)")
    self.setDistance(distance: store.distance)
    self.titleLabel.text = store.storeName
    self.setRating(rating: store.rating)
    self.setCategories(categories: store.categories)
  }
  
  private func setDistance(distance: Int) {
    if distance >= 1000 {
      distanceLabel.text = "1km+"
    } else {
      distanceLabel.text = "\(distance)m"
    }
  }
  
  private func setRating(rating: Double) {
    if floor(rating) == rating {
      self.rankLabel.text = "\(Int(rating))점"
    } else {
      self.rankLabel.text = String(format: "%.1f점", rating)
    }
  }
  
  private func setCategories(categories: [StoreCategory]) {
    var categoryString = ""
    for category in categories {
      categoryString.append("#\(category.name) ")
    }
    self.categoriesLabel.text = categoryString
  }
}
