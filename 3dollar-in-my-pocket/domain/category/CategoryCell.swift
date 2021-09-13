import UIKit

class CategoryCell: BaseCollectionViewCell {
  
  static let registerId = "\(CategoryCell.self)"
  
  let categoryImage = UIImageView()
  
  let categoryLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 14)
    $0.textColor = .black
  }
  
  
  override func setup() {
    self.backgroundColor = .white
    self.layer.cornerRadius = 17
    self.addSubViews(categoryImage, categoryLabel)
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(10 * RatioUtils.heightRatio)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.categoryImage.snp.bottom).offset(4)
    }
  }
  
  func bind(category: StoreCategory) {
    self.categoryLabel.text = category.name
    self.categoryImage.image = category.image
  }
}
