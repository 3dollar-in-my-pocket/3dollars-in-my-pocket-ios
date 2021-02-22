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
    switch category {
    case .BUNGEOPPANG:
      self.categoryImage.image = UIImage(named: "img_60_bungeoppang")
      self.categoryLabel.text = "shared_category_bungeoppang".localized
    case .GYERANPPANG:
      self.categoryImage.image = UIImage(named: "img_60_gyeranppang")
      self.categoryLabel.text = "shared_category_gyeranppang".localized
    case .TAKOYAKI:
      self.categoryImage.image = UIImage(named: "img_60_takoyaki")
      self.categoryLabel.text = "shared_category_takoyaki".localized
    case .HOTTEOK:
      self.categoryImage.image = UIImage(named: "img_60_hotteok")
      self.categoryLabel.text = "shared_category_hotteok".localized
    case .EOMUK:
      self.categoryImage.image = UIImage(named: "img_60_eomuk")
      self.categoryLabel.text = "shared_category_eomuk".localized
    case .GUKHWAPPANG:
      self.categoryImage.image = UIImage(named: "img_60_gukhwappang")
      self.categoryLabel.text = "shared_category_gukhwappang".localized
    case .GUNGOGUMA:
      self.categoryImage.image = UIImage(named: "img_60_gungoguma")
      self.categoryLabel.text = "shared_category_gungoguma".localized
    case .GUNOKSUSU:
      self.categoryImage.image = UIImage(named: "img_60_gunoksusu")
      self.categoryLabel.text = "shared_category_gunoksusu".localized
    case .KKOCHI:
      self.categoryImage.image = UIImage(named: "img_60_kkochi")
      self.categoryLabel.text = "shared_category_kkochi".localized
    case .SUNDAE:
      self.categoryImage.image = UIImage(named: "img_60_sundae")
      self.categoryLabel.text = "shared_category_sundae".localized
    case .TOAST:
      self.categoryImage.image = UIImage(named: "img_60_toast")
      self.categoryLabel.text = "shared_category_toast".localized
    case .TTANGKONGPPANG:
      self.categoryImage.image = UIImage(named: "img_60_ttangkongppang")
      self.categoryLabel.text = "shared_category_ttangkongppang".localized
    case .TTEOKBOKI:
      self.categoryImage.image = UIImage(named: "img_60_tteokboki")
      self.categoryLabel.text = "shared_category_tteokboki".localized
    case .WAFFLE:
      self.categoryImage.image = UIImage(named: "img_60_waffle")
      self.categoryLabel.text = "shared_category_waffle".localized
    }
  }
}
