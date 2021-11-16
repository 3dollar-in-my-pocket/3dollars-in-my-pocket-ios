import UIKit

class StoreCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreCell.self)"
  static let itemSize: CGSize = CGSize(width: 272, height: 120)
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 4, height: 4)
    $0.layer.shadowOpacity = 0.08
  }
  
  let categoryImage = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = R.color.gray90()
    $0.font = R.font.appleSDGothicNeoEB00(size: 16)
  }
  
  private let bedgeImage = UIImageView().then {
    $0.image = R.image.img_bedge()
    $0.isHidden = true
  }
  
  let categoriesLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
    $0.textColor = R.color.gray40()
  }
  
  let distanceImage = UIImageView().then {
    $0.image = R.image.ic_near_filled()
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = R.color.gray80()
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let starImage = UIImageView().then {
    $0.image = R.image.ic_star()
  }
  
  let rankLabel = UILabel().then {
    $0.textColor = R.color.gray90()
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let visitButton = UIButton().then {
    $0.backgroundColor = R.color.red()
    $0.layer.cornerRadius = 13
    $0.setTitle("방문하기", for: .normal)
    $0.titleEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 0)
    $0.titleLabel?.font = .bold(size: 12)
    $0.setImage(R.image.ic_dest(), for: .normal)
  }
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.setSelected(isSelected: false)
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(
      self.containerView,
      self.categoryImage,
      self.titleLabel,
      self.bedgeImage,
      self.categoriesLabel,
      self.distanceImage,
      self.distanceLabel,
      self.starImage,
      self.rankLabel,
      self.visitButton
    )
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.size.equalTo(Self.itemSize)
      make.bottom.equalToSuperview().offset(-10)
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.top.equalTo(self.containerView).offset(16)
      make.width.height.equalTo(40)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.containerView).offset(18)
      make.left.equalTo(self.categoryImage.snp.right).offset(8)
      make.right.equalTo(self.containerView).offset(-16)
    }
    
    self.bedgeImage.snp.makeConstraints { make in
      make.top.equalTo(self.containerView).offset(16)
      make.right.equalTo(self.containerView).offset(-14)
      make.width.height.equalTo(24)
    }
    
    self.categoriesLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.titleLabel)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
    }
    
    self.distanceImage.snp.makeConstraints { make in
      make.left.equalTo(self.titleLabel)
      make.bottom.equalTo(self.containerView).offset(-16)
      make.width.height.equalTo(16)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.left.equalTo(self.distanceImage.snp.right).offset(4)
      make.centerY.equalTo(self.distanceImage)
    }
    
    self.starImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.distanceImage)
      make.left.equalTo(self.distanceLabel.snp.right).offset(10)
      make.width.height.equalTo(16)
    }
    
    self.rankLabel.snp.makeConstraints { make in
      make.left.equalTo(self.starImage.snp.right).offset(4)
      make.centerY.equalTo(self.distanceLabel)
    }
    
    self.visitButton.snp.makeConstraints { make in
      make.right.equalTo(self.containerView).offset(-14)
      make.bottom.equalTo(self.containerView).offset(-14)
      make.height.equalTo(26)
      make.width.equalTo(74)
    }
  }
  
  func setSelected(isSelected: Bool) {
    if isSelected {
      self.containerView.backgroundColor = .black
      self.titleLabel.textColor = .white
      self.categoriesLabel.textColor = R.color.pink()
      self.distanceLabel.textColor = .white
      self.distanceImage.image = R.image.ic_near_white()
      self.rankLabel.textColor = .white
      self.starImage.image = R.image.ic_star_white()
    } else {
      self.containerView.backgroundColor = .white
      self.titleLabel.textColor = .black
      self.categoriesLabel.textColor = R.color.gray60()
      self.distanceLabel.textColor = R.color.gray90()
      self.distanceImage.image = R.image.ic_near_filled()
      self.rankLabel.textColor = R.color.gray90()
      self.starImage.image = R.image.ic_star()
    }
  }
  
  func bind(store: Store) {
    self.categoryImage.image = UIImage(named: "img_60_\(store.categories[0].lowcase)")
    self.setDistance(distance: store.distance)
    self.titleLabel.text = store.storeName
    self.setRating(rating: store.rating)
    self.setCategories(categories: store.categories)
    self.bedgeImage.isHidden = !store.isCertificated
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
