import UIKit

final class StoreDetailMenuCategoryView: BaseView {
  
  let categoryImage = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  let categoryLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let emptyLabel = UILabel().then {
    $0.text = "store_detail_empty_menu".localized
    $0.textColor = UIColor(r: 161, g: 161, b: 161)
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 14)
    $0.isHidden = true
  }
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(categoryImage, categoryLabel, emptyLabel)
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
    
    self.emptyLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.categoryImage)
    }
  }
  
  func bind(category: StoreCategory, isEmpty: Bool) {
    self.emptyLabel.isHidden = !isEmpty
    self.categoryImage.image = UIImage(named: "img_32_\(category.lowcase)_on")
    self.categoryLabel.text = "shared_category_\(category.lowcase)".localized
  }
}
