import UIKit

class MyPageReviewCell: BaseTableViewCell {
  
  static let registerId = "\(MyPageReviewCell.self)"
  
  let categoryImage = UIImageView()
  
  let reviewLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.textColor = .white
  }
  
  let star1 = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star2 = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star3 = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star4 = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let star5 = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
    $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    $0.isUserInteractionEnabled = false
  }
  
  let stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .leading
    $0.backgroundColor = .clear
    $0.spacing = 3
  }
  
  
  override func setup() {
    self.selectionStyle = .none
    self.stackView.addArrangedSubview(star1)
    self.stackView.addArrangedSubview(star2)
    self.stackView.addArrangedSubview(star3)
    self.stackView.addArrangedSubview(star4)
    self.stackView.addArrangedSubview(star5)
    self.addSubViews(categoryImage, reviewLabel, stackView)
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(4)
      make.bottom.equalToSuperview().offset(-4)
      make.width.height.equalTo(32)
    }
    
    self.star1.snp.makeConstraints { make in
      make.width.height.equalTo(12)
    }
    
    self.star2.snp.makeConstraints { make in
      make.width.height.equalTo(12)
    }
    
    self.star3.snp.makeConstraints { make in
      make.width.height.equalTo(12)
    }
    
    self.star4.snp.makeConstraints { make in
      make.width.height.equalTo(12)
    }
    
    self.star5.snp.makeConstraints { make in
      make.width.height.equalTo(12)
    }
    
    self.stackView.snp.makeConstraints { make in
      make.centerY.equalTo(categoryImage.snp.centerY)
      make.right.equalToSuperview().offset(-13)
    }
    
    self.reviewLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.categoryImage)
      make.left.equalTo(self.categoryImage.snp.right).offset(16)
      make.right.equalTo(self.stackView.snp.left).offset(-8)
    }
  }
  
  func setTopRadius() {
    self.layer.cornerRadius = 8
    self.layer.masksToBounds = true
    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  func setBottomRadius() {
    self.layer.cornerRadius = 8
    self.layer.masksToBounds = true
    self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
  }
  
  func setOddBg() {
    self.backgroundColor = UIColor.init(r: 69, g: 69, b: 69)
  }
  
  func setEvenBg() {
    self.backgroundColor = UIColor.init(r: 46, g: 46, b: 46)
  }
  
  func bind(review: Review?) {
    self.categoryImage.isHidden = review == nil
    self.reviewLabel.isHidden = review == nil
    self.stackView.isHidden = review == nil
    
    if let review = review {
      self.categoryImage.image = UIImage(named: "img_32_\(review.category.lowcase)_on")
      self.reviewLabel.text = review.contents
      self.setRank(rank: review.rating)
    }
  }
  
  func setRank(rank: Int) {
    for index in 0...self.stackView.arrangedSubviews.count - 1 {
      if let star = self.stackView.arrangedSubviews[index] as? UIButton {
        star.isSelected = index < rank
      }
    }
  }
}
