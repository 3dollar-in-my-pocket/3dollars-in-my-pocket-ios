import UIKit

class CategoryListStoreCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListStoreCell.self)"
  static let height: CGFloat = 90
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
  }
  
  private let titleStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
  }
  
  private let bedgedImage = UIImageView().then {
    $0.image = R.image.img_bedge()
  }
  
  private let titleLabel = UILabel().then {
    $0.textColor = R.color.black()
    $0.font = R.font.appleSDGothicNeoEB00(size: 16)
  }
  
  private let categoriesLabel = UILabel().then {
    $0.textColor = R.color.gray60()
    $0.font = .regular(size: 12)
  }
  
  private let distanceImage = UIImageView().then {
    $0.image = R.image.ic_near_filled()
  }
  
  private let distanceLabel = UILabel().then {
    $0.textColor = R.color.black()
    $0.font = .medium(size: 14)
  }
  
  private let ratingImage = UIImageView().then {
    $0.image = R.image.ic_star_gray()
  }
  
  private let ratingLabel = UILabel().then {
    $0.textColor = R.color.black()
    $0.font = .medium(size: 14)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.titleStackView.subviews.forEach { $0.removeFromSuperview()}
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.addSubViews([
      self.containerView,
      self.titleStackView,
      self.categoriesLabel,
      self.ratingLabel,
      self.ratingImage,
      self.distanceLabel,
      self.distanceImage
    ])
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalToSuperview()
    }
    
    self.titleStackView.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.top.equalTo(self.containerView).offset(20)
    }
    
    self.bedgedImage.snp.makeConstraints { make in
      make.width.height.equalTo(16)
    }
    
    self.categoriesLabel.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.bottom.equalTo(self.containerView).offset(-14)
    }
    
    self.ratingLabel.snp.makeConstraints { (make) in
      make.right.equalTo(self.containerView).offset(-21)
      make.centerY.equalTo(self.categoriesLabel)
    }
    
    self.ratingImage.snp.makeConstraints { make in
      make.right.equalTo(self.ratingLabel.snp.left).offset(-4)
      make.centerY.equalTo(self.categoriesLabel)
      make.width.height.equalTo(16)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.right.equalTo(self.ratingImage.snp.left).offset(-8)
      make.centerY.equalTo(self.categoriesLabel)
    }

    self.distanceImage.snp.makeConstraints { make in
      make.right.equalTo(self.distanceLabel.snp.left).offset(-4)
      make.centerY.equalTo(self.categoriesLabel)
      make.width.height.equalTo(16)
    }
  }
  
  func bind(store: Store?) {
    if let store = store {
      self.titleLabel.text = store.storeName
      
      if store.isCertificated {
        self.titleStackView.addArrangedSubview(self.bedgedImage)
      }
      self.titleStackView.addArrangedSubview(self.titleLabel)
      self.ratingLabel.text = String.init(format: "%.01f", store.rating)
      if store.distance >= 1000 {
        self.distanceLabel.text = String.init(format: "%.2fkm", Double(store.distance) / 1000)
      } else {
        self.distanceLabel.text = String.init(format: "%dm", store.distance)
      }
      self.categoriesLabel.text = store.categoriesString
    } else {
      // TODO: 광고 배너 바인딩 필요
    }
  }
  
  func bind(storeCard: StoreCard?) {
    if let storeCard = storeCard {
      self.titleLabel.text = storeCard.storeName
      self.ratingLabel.text = String.init(format: "%.01f", storeCard.rating)
      self.ratingLabel.sizeToFit()
      
      if storeCard.distance >= 1000 {
        self.distanceLabel.text = String.init(format: "%.2fkm", Double(storeCard.distance) / 1000)
      } else {
        self.distanceLabel.text = String.init(format: "%dm", storeCard.distance)
      }
      self.distanceLabel.sizeToFit()
      
      var categories = ""
      for category in storeCard.categories {
        categories.append("#\(category.name) ")
      }
      self.categoriesLabel.text = categories
    }
  }
}
