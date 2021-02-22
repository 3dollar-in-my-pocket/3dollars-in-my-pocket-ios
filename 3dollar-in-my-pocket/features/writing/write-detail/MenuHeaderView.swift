import UIKit

class MenuHeaderView: BaseView {
  
  let categoryImage = UIImageView()
  
  let titleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let deleteButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_delete_category"), for: .normal)
  }
  
  override func setup() {
    backgroundColor = .white
    addSubViews(categoryImage, titleLabel, deleteButton)
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.width.height.equalTo(32)
      make.top.equalToSuperview().offset(18)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.categoryImage)
      make.left.equalTo(self.categoryImage.snp.right).offset(8)
    }
    
    self.deleteButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.width.height.equalTo(24)
      make.centerY.equalTo(self.categoryImage)
    }
  }
  
  func bind(category: StoreCategory) {
    switch category {
    case .BUNGEOPPANG:
      self.categoryImage.image = UIImage(named: "img_32_bungeoppang_on")
      self.titleLabel.text = "shared_category_bungeoppang".localized
    case .GYERANPPANG:
      self.categoryImage.image = UIImage(named: "img_32_gyeranppang_on")
      self.titleLabel.text = "shared_category_gyeranppang".localized
    case .HOTTEOK:
      self.categoryImage.image = UIImage(named: "img_32_hotteok_on")
      self.titleLabel.text = "shared_category_hotteok".localized
    case .TAKOYAKI:
      self.categoryImage.image = UIImage(named: "img_32_takoyaki_on")
      self.titleLabel.text = "shared_category_takoyaki".localized
    default:
      break
    }
  }
}
