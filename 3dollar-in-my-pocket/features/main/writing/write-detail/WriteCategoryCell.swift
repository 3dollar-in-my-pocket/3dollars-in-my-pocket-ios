import UIKit

class WriteCategoryCell: BaseCollectionViewCell {
  
  static let registerId = "\(CategoryCell.self)"
  
  let roundView = UIView().then {
    $0.layer.cornerRadius = 26
    $0.layer.masksToBounds = true
    $0.backgroundColor = .black
  }
  
  let categoryImage = UIImageView().then {
    $0.image = UIImage(named: "ic_plus_pink")
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
    addSubViews(roundView, categoryImage, nameLabel)
  }
  
  override func bindConstraints() {
    self.roundView.snp.makeConstraints { make in
      make.width.height.equalTo(52)
      make.top.left.right.equalToSuperview()
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.center.equalTo(self.roundView)
      make.width.height.equalTo(32)
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.roundView)
      make.top.equalTo(self.roundView.snp.bottom).offset(8)
      make.height.equalTo(self.nameLabel.intrinsicContentSize.height)
      make.bottom.equalToSuperview()
    }
  }
  
  func bind(category: StoreCategory?) {
    if let category = category {
      self.roundView.backgroundColor = .clear
      self.roundView.layer.borderWidth = 1
      self.roundView.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
      switch category {
      case .BUNGEOPPANG:
        self.categoryImage.image = UIImage(named: "img_category_fish")
        self.nameLabel.text = "shared_category_bungeoppang".localized
      case .GYERANPPANG:
        self.categoryImage.image = UIImage(named: "img_category_gyeranppang")
        self.nameLabel.text = "shared_category_gyeranppang".localized
      case .HOTTEOK:
        self.categoryImage.image = UIImage(named: "img_category_hotteok")
        self.nameLabel.text = "shared_category_hotteok".localized
      case .TAKOYAKI:
        self.categoryImage.image = UIImage(named: "img_category_takoyaki")
        self.nameLabel.text = "shared_category_takoyaki".localized
      }
    }
  }
}
