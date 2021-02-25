import UIKit

class CategoryListStoreCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListStoreCell.self)"
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 16)
  }
  
  let categoriesLabel = UILabel().then {
    $0.textColor = UIColor(r: 114, g: 114, b: 114)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
  }
  
  let ratingLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let ratingImage = UIImageView().then {
    $0.image = UIImage(named: "ic_star")
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let distanceImage = UIImageView().then {
    $0.image = UIImage(named: "ic_near_filled")
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.addSubViews(
      containerView, titleLabel, categoriesLabel, ratingLabel,
      ratingImage, distanceLabel, distanceImage
    )
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalToSuperview().offset(-5)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.right.equalTo(self.containerView).offset(-16)
      make.top.equalTo(self.containerView).offset(16)
    }
    
    self.categoriesLabel.snp.makeConstraints { make in
      make.left.equalTo(self.titleLabel)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
      make.bottom.equalTo(self.containerView).offset(-14)
    }
    
    self.ratingLabel.snp.makeConstraints { (make) in
      make.right.equalTo(self.containerView).offset(-14)
      make.width.lessThanOrEqualTo(40)
      make.centerY.equalTo(self.categoriesLabel)
    }
    
    self.ratingImage.snp.makeConstraints { make in
      make.right.equalTo(self.ratingLabel.snp.left).offset(-4)
      make.centerY.equalTo(self.categoriesLabel)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.right.equalTo(self.ratingImage.snp.left).offset(-8)
      make.centerY.equalTo(self.categoriesLabel)
      make.width.lessThanOrEqualTo(50)
    }

    self.distanceImage.snp.makeConstraints { make in
      make.right.equalTo(self.distanceLabel.snp.left).offset(-4)
      make.centerY.equalTo(self.categoriesLabel)
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
      
      var categories = "#\(storeCard.category.name) "
      for category in storeCard.categories {
        categories.append("#\(category.name) ")
      }
      self.categoriesLabel.text = categories
    }
  }
}
