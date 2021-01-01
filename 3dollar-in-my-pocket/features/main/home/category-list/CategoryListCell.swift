import UIKit

class CategoryListCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListCell.self)"
  
  let categoryImage = UIImageView().then {
    $0.image = UIImage.init(named: "img_review_bungeoppang")
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = UIColor.init(r: 44, g: 44, b: 44)
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = UIColor.init(r: 189, g: 189, b: 189)
    $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 14)
    $0.isHidden = true
  }
  
  let valueLabel = UILabel().then {
    $0.textColor = UIColor.init(r: 28, g: 28, b: 28)
    $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
  }
  
  let starImg = UIImageView().then {
    $0.image = UIImage.init(named: "ic_star_on")
    $0.isHidden = true
  }
  
  override func setup() {
    backgroundColor = .white
    selectionStyle = .none
    addSubViews(categoryImage, titleLabel, distanceLabel, valueLabel, starImg)
  }
  
  override func bindConstraints() {
    categoryImage.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(12)
      make.bottom.equalToSuperview().offset(-12)
      make.left.equalToSuperview().offset(16)
      make.width.equalTo(40)
      make.height.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(categoryImage.snp.centerY)
      make.left.equalTo(categoryImage.snp.right).offset(16)
      make.width.lessThanOrEqualTo(150 * RatioUtils.widthRatio)
    }
    
    distanceLabel.snp.makeConstraints { (make) in
      make.left.equalTo(titleLabel.snp.right).offset(8)
      make.bottom.equalTo(titleLabel)
    }
    
    valueLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(categoryImage.snp.centerY)
      make.right.equalToSuperview().offset(-16)
    }
    
    starImg.snp.makeConstraints { (make) in
      make.centerY.equalTo(valueLabel)
      make.right.equalTo(valueLabel.snp.left).offset(-3)
      make.width.height.equalTo(19)
    }
  }
  
  func bind(order: Order, storeCard: StoreCard) {
    switch storeCard.category {
    case .BUNGEOPPANG:
      categoryImage.image = UIImage.init(named: "img_40_bungeoppang")
    case .GYERANPPANG:
      categoryImage.image = UIImage.init(named: "img_40_gyeranppang")
    case .HOTTEOK:
      categoryImage.image = UIImage.init(named: "img_40_hotteok")
    case .TAKOYAKI:
      categoryImage.image = UIImage.init(named: "img_40_takoyaki")
    }
    titleLabel.text = storeCard.storeName
    
    switch order {
    case .DISTANCE:
      if storeCard.distance >= 1000 {
        valueLabel.text = String.init(format: "%.2fkm", Double(storeCard.distance) / 1000)
      } else {
        valueLabel.text = String.init(format: "%dm", storeCard.distance)
      }
      starImg.isHidden = true
      distanceLabel.isHidden = true
    case .REVIEW:
      valueLabel.text = String.init(format: "%.01f", storeCard.rating)
      starImg.isHidden = false
      distanceLabel.isHidden = false
      
      if storeCard.distance >= 1000 {
        distanceLabel.text = String.init(format: "%.2fkm", Double(storeCard.distance) / 1000)
      } else {
        distanceLabel.text = String.init(format: "%dm", storeCard.distance)
      }
    }
    
  }
  
  func setBottomRadius(isLast: Bool) {
    if isLast {
      layer.cornerRadius = 12
      layer.masksToBounds = true
      layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else {
      layer.cornerRadius = 0
      layer.masksToBounds = false
    }
  }
  
  func setOddBg() {
    backgroundColor = UIColor.init(r: 250, g: 250, b: 250)
  }
  
  func setEvenBg() {
    backgroundColor = .white
  }
}
