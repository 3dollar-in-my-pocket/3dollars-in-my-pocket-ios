import UIKit

class StoreDetailMenuCategoryView: BaseView {
  
  let categoryImage = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  let categoryLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(categoryImage, categoryLabel)
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(11)
      make.bottom.equalToSuperview().offset(-2)
      make.width.equalTo(24)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.categoryImage)
      make.left.equalTo(self.categoryImage.snp.right).offset(8)
    }
  }
  
  func bind(category: StoreCategory) {
    switch category {
    case .BUNGEOPPANG:
      self.categoryImage.image = UIImage(named: "img_32_bungeoppang_on")
      self.categoryLabel.text = "shared_category_bungeoppang".localized
    case .GYERANPPANG:
      self.categoryImage.image = UIImage(named: "img_32_gyeranppang_on")
      self.categoryLabel.text = "shared_category_gyeranppang".localized
    case .HOTTEOK:
      self.categoryImage.image = UIImage(named: "img_32_hotteok_on")
      self.categoryLabel.text = "shared_category_hotteok".localized
    case .TAKOYAKI:
      self.categoryImage.image = UIImage(named: "img_32_takoyaki_on")
      self.categoryLabel.text = "shared_category_takoyaki".localized
    }
  }
}
