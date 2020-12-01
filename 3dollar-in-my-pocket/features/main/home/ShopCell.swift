import UIKit

class ShopCell: BaseCollectionViewCell {
  
  static let registerId = "\(ShopCell.self)"
  
  let distanceLabel = UILabel().then {
    $0.text = "100m"
    $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    $0.textAlignment = .center
    $0.layer.cornerRadius = 12.5
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
  }
  
  let imageBtn = UIButton().then {
    $0.setImage(UIImage.init(named: "img_card_bungeoppang_off"), for: .normal)
    $0.setImage(UIImage.init(named: "img_card_bungeoppang_on"), for: .selected)
    $0.contentMode = .scaleAspectFit
    $0.isUserInteractionEnabled = false
  }
  
  let titleLabl = UILabel().then {
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 15)
    $0.textColor = UIColor(r: 200, g: 200, b: 200)
    $0.textAlignment = .center
  }
  
  let rankLabel = UILabel().then {
    $0.textColor = UIColor(r: 200, g: 200, b: 200)
    $0.font = UIFont(name: "SpoqaHanSans-Regular", size: 12)
  }
  
  let starImage = UIImageView().then {
    $0.image = UIImage(named: "ic_star_on")
  }
  
  
  override func setup() {
    layer.cornerRadius = 16
    backgroundColor = UIColor.init(r: 251, g: 251, b: 251)
    setupShadow()
    addSubViews(distanceLabel, imageBtn, starImage, rankLabel, titleLabl)
  }
  
  override func bindConstraints() {
    distanceLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(15)
      make.width.equalTo(56)
      make.height.equalTo(25)
    }
    
    imageBtn.snp.makeConstraints { (make) in
      make.top.equalTo(distanceLabel.snp.bottom).offset(8)
      make.left.equalToSuperview().offset(25)
      make.right.equalToSuperview().offset(-25)
    }
    
    self.rankLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-16)
      make.centerY.equalTo(self.distanceLabel)
    }
    
    self.starImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.rankLabel)
      make.right.equalTo(self.rankLabel.snp.left).offset(-2)
      make.width.height.equalTo(14)
    }
    
    self.titleLabl.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.bottom.equalToSuperview().offset(-16)
    }
  }
  
  func setSelected(isSelected: Bool) {
    if isSelected {
      layer.backgroundColor = UIColor.init(r: 28, g: 28, b: 28).cgColor
      self.titleLabl.textColor = .white
      self.rankLabel.textColor = .white
    } else {
      layer.backgroundColor = UIColor.init(r: 251, g: 251, b: 251).cgColor
      self.titleLabl.textColor = UIColor(r: 200, g: 200, b: 200)
      self.rankLabel.textColor = UIColor(r: 200, g: 200, b: 200)
    }
    imageBtn.isSelected = isSelected
  }
  
  func bind(storeCard: StoreCard) {
    switch storeCard.category {
    case .BUNGEOPPANG:
      imageBtn.setImage(UIImage.init(named: "img_card_bungeoppang_off"), for: .normal)
      imageBtn.setImage(UIImage.init(named: "img_card_bungeoppang_on"), for: .selected)
    case .GYERANPPANG:
      imageBtn.setImage(UIImage.init(named: "img_card_gyeranppang_off"), for: .normal)
      imageBtn.setImage(UIImage.init(named: "img_card_gyeranppang_on"), for: .selected)
    case .HOTTEOK:
      imageBtn.setImage(UIImage.init(named: "img_card_hotteok_off"), for: .normal)
      imageBtn.setImage(UIImage.init(named: "img_card_hotteok_on"), for: .selected)
    case .TAKOYAKI:
      imageBtn.setImage(UIImage.init(named: "img_card_takoyaki_off"), for: .normal)
      imageBtn.setImage(UIImage.init(named: "img_card_takoyaki_on"), for: .selected)
    default:
      break
    }
    if storeCard.distance >= 1000 {
      distanceLabel.text = "1km+"
    } else {
      distanceLabel.text = "\(storeCard.distance!)m"
    }
    
    self.titleLabl.text = storeCard.storeName
    if let rating = storeCard.rating {
      self.rankLabel.text = "\(rating)점"
    }
  }
  
  private func setupShadow() {
    layer.masksToBounds = false
    layer.shadowOffset = CGSize(width: 10, height: 10)
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 16
    layer.shadowOpacity = 0.2
    
    let backgroundCGColor = backgroundColor?.cgColor
    backgroundColor = nil
    layer.backgroundColor =  backgroundCGColor
  }
}
