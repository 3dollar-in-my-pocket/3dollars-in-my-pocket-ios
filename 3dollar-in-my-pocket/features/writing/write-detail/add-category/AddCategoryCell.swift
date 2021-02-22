import UIKit

class AddCategoryCell: BaseCollectionViewCell {
  
  static let registerId = "\(AddCategoryCell.self)"
  
  let roundView = UIView().then {
    $0.layer.cornerRadius = 26
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
    $0.layer.borderWidth = 1
    $0.backgroundColor = .clear
  }
  
  let categoryImage = UIImageView()
  
  let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.textAlignment = .center
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
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
      make.width.equalTo(32)
      make.height.equalTo(32)
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.roundView)
      make.top.equalTo(self.roundView.snp.bottom).offset(8)
      make.bottom.equalToSuperview()
    }
  }
  
  func bind(category: StoreCategory, isSelected: Bool) {
    if isSelected {
      self.roundView.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
      switch category {
      case .BUNGEOPPANG:
        self.categoryImage.image = UIImage(named: "img_32_bungeoppang_on")
        self.nameLabel.text = "shared_category_bungeoppang".localized
      case .GYERANPPANG:
        self.categoryImage.image = UIImage(named: "img_32_gyeranppang_on")
        self.nameLabel.text = "shared_category_gyeranppang".localized
      case .HOTTEOK:
        self.categoryImage.image = UIImage(named: "img_32_hotteok_on")
        self.nameLabel.text = "shared_category_hotteok".localized
      case .TAKOYAKI:
        self.categoryImage.image = UIImage(named: "img_32_takoyaki_on")
        self.nameLabel.text = "shared_category_takoyaki".localized
      }
      self.nameLabel.textColor = UIColor(r: 28, g: 28, b: 28)
    } else {
      self.roundView.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
      switch category {
      case .BUNGEOPPANG:
        self.categoryImage.image = UIImage(named: "img_32_bungeoppang_off")
        self.nameLabel.text = "shared_category_bungeoppang".localized
      case .GYERANPPANG:
        self.categoryImage.image = UIImage(named: "img_32_gyeranppang_off")
        self.nameLabel.text = "shared_category_gyeranppang".localized
      case .HOTTEOK:
        self.categoryImage.image = UIImage(named: "img_32_hotteok_off")
        self.nameLabel.text = "shared_category_hotteok".localized
      case .TAKOYAKI:
        self.categoryImage.image = UIImage(named: "img_32_takoyaki_off")
        self.nameLabel.text = "shared_category_takoyaki".localized
      }
      self.nameLabel.textColor = UIColor(r: 137, g: 137, b: 137)
    }
  }
}
