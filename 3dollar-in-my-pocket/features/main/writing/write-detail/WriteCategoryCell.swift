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
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.roundView)
      make.top.equalTo(self.roundView.snp.bottom).offset(8)
      make.bottom.equalToSuperview()
    }
  }
  
  func bind(category: StoreCategory?) {
    
  }
}
