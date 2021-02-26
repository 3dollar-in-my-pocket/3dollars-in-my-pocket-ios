import UIKit

class RegisteredStoreCell: BaseTableViewCell {
  
  static let registerId = "\(RegisteredStoreCell.self)"
  
  let containerView = UIView().then {
    $0.backgroundColor = UIColor.init(r: 46, g: 46, b: 46)
    $0.layer.cornerRadius = 12
  }
  
  let categoryImage = UIImageView()
  
  let titleLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 16)
    $0.textColor = .white
  }
  
  let categoriesLabel = UILabel().then {
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
  }
  
  let distanceImage = UIImageView().then {
    $0.image = UIImage(named: "ic_near_filled")
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let starImage = UIImageView().then {
    $0.image = UIImage(named: "ic_star")
  }
  
  let rankLabel = UILabel().then {
    $0.textColor = UIColor(r: 200, g: 200, b: 200)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
    $0.textColor = .white
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.addSubViews(
      containerView, categoryImage, titleLabel, categoriesLabel,
      distanceImage, distanceLabel, starImage, rankLabel
    )
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(8)
      make.bottom.equalToSuperview().offset(-8)
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.centerY.equalTo(self.containerView)
      make.top.equalTo(self.containerView).offset(22)
      make.bottom.equalToSuperview().offset(-22)
      make.width.height.equalTo(60)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.containerView).offset(20)
      make.left.equalTo(self.categoryImage.snp.right).offset(13)
      make.right.equalToSuperview().offset(-16)
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
  
  func bind(store: Store) {
    self.categoryImage.image = UIImage(named: "img_60_\(store.category.lowcase)")
    self.titleLabel.text = store.storeName
    self.rankLabel.text = "\(store.rating)점"
    if store.distance >= 1000 {
      distanceLabel.text = "1km+"
    } else {
      distanceLabel.text = "\(store.distance)m"
    }
    
    var categories = ""
    for category in store.categories {
      categories.append("#\(category.name) ")
    }
    self.categoriesLabel.text = categories
  }
}
