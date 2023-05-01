import UIKit

class WriteCategoryCell: BaseCollectionViewCell {
  
  static let registerId = "\(WriteCategoryCell.self)"
  
  let categoryCellWidth = ((UIScreen.main.bounds.width - 48) - (17 * 4)) / 5
  
  lazy var roundView = UIView().then {
    $0.layer.cornerRadius = self.categoryCellWidth / 2
    $0.layer.masksToBounds = true
    $0.backgroundColor = .black
  }
  
  let categoryImage = UIImageView().then {
    $0.image = UIImage(named: "ic_plus_pink")
  }
  
  let deleteButton = UIImageView().then {
    $0.image = UIImage(named: "ic_delete_small")
  }
  
  let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.textAlignment = .center
    $0.text = "write_store_add_category".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.roundView.backgroundColor = .black
    self.roundView.layer.borderWidth = 0
    self.categoryImage.image = UIImage(named: "ic_plus_pink")
    self.nameLabel.text = "write_store_add_category".localized
  }
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(roundView, categoryImage, deleteButton, nameLabel)
  }
  
  override func bindConstraints() {
    self.roundView.snp.makeConstraints { make in
      make.width.height.equalTo(self.categoryCellWidth)
      make.top.left.right.equalToSuperview()
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.center.equalTo(self.roundView)
      make.left.equalTo(self.roundView).offset(10)
      make.top.equalTo(self.roundView).offset(10)
      make.right.equalTo(self.roundView).offset(-10)
      make.bottom.equalTo(self.roundView).offset(-10)
    }
    
    self.deleteButton.snp.makeConstraints { make in
      make.top.equalTo(self.roundView)
      make.centerX.equalTo(self.roundView.snp.right).offset(-4)
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.roundView)
      make.top.equalTo(self.roundView.snp.bottom).offset(8)
      make.height.equalTo(self.nameLabel.intrinsicContentSize.height)
      make.bottom.equalToSuperview()
    }
  }
  
  func bind(category: StreetFoodStoreCategory?) {
    self.deleteButton.isHidden = (category == nil)
    if let category = category {
      self.roundView.backgroundColor = .clear
      self.roundView.layer.borderWidth = 1
      self.roundView.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
      self.categoryImage.image = UIImage(named: "img_32_\(category.lowcase)_on")
      self.nameLabel.text = "shared_category_\(category.lowcase)".localized
    }
  }
}
