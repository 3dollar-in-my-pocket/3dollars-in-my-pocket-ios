import UIKit

class StoreDetailMenuCategoryView: BaseView {
  
  let categoryImage = UIImageView().then {
    $0.image = UIImage(named: "img_40_bungeoppang")
    $0.contentMode = .scaleAspectFit
  }
  
  let categoryLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.text = "붕어빵"
  }
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(categoryImage, categoryLabel)
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(11)
      make.bottom.equalToSuperview().offset(-7)
      make.width.equalTo(27)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.categoryImage)
      make.left.equalTo(self.categoryImage.snp.right).offset(8)
    }
  }
}
