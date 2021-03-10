import UIKit

class MyReviewCell: BaseTableViewCell {
  
  static let registerId = "\(MyReviewCell.self)"
  
  let titleLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
    $0.textColor = UIColor.init(r: 255, g: 161, b: 170)
  }
  
  let containerView = UIView().then {
    $0.backgroundColor = UIColor(r: 46, g: 46, b: 46)
    $0.layer.cornerRadius = 12
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
  }
  
  let moreButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_more"), for: .normal)
  }
  
  let nameLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
  }
  
  let createdAtLabel = UILabel().then {
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
  }
  
  let reviewLabel = UILabel().then {
    $0.textColor = .white
    $0.numberOfLines = 0
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.contentView.isUserInteractionEnabled = false
    self.stackView.addArrangedSubview(star1)
    self.stackView.addArrangedSubview(star2)
    self.stackView.addArrangedSubview(star3)
    self.stackView.addArrangedSubview(star4)
    self.stackView.addArrangedSubview(star5)
    self.addSubViews(
      titleLabel, containerView, stackView, moreButton,
      nameLabel, createdAtLabel, reviewLabel
    )
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(12)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(14)
      make.bottom.equalTo(self.reviewLabel).offset(16)
      make.bottom.equalToSuperview().offset(-12)
    }
    
    self.star1.snp.makeConstraints { make in
      make.width.height.equalTo(16)
    }
    
    self.star2.snp.makeConstraints { make in
      make.width.height.equalTo(16)
    }
    
    self.star3.snp.makeConstraints { make in
      make.width.height.equalTo(16)
    }
    
    self.star4.snp.makeConstraints { make in
      make.width.height.equalTo(16)
    }
    
    self.star5.snp.makeConstraints { make in
      make.width.height.equalTo(16)
    }
    
    self.stackView.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.height.equalTo(14)
      make.top.equalTo(self.containerView).offset(16)
    }
    
    self.moreButton.snp.makeConstraints { make in
      make.right.equalTo(self.containerView).offset(-12)
      make.centerY.equalTo(self.stackView)
      make.width.height.equalTo(18)
    }
    
    self.nameLabel.snp.makeConstraints { (make) in
      make.left.equalTo(self.stackView)
      make.top.equalTo(stackView.snp.bottom).offset(8)
    }
    
    self.createdAtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.nameLabel)
      make.left.equalTo(nameLabel.snp.right).offset(8)
    }
    
    self.reviewLabel.snp.makeConstraints { (make) in
      make.left.equalTo(self.nameLabel)
      make.right.equalTo(containerView).offset(-16)
      make.top.equalTo(nameLabel.snp.bottom).offset(8)
    }
  }
  
  func bind(review: Review) {
    self.titleLabel.text = review.storeName
    self.reviewLabel.text = review.contents
    self.setRank(rank: review.rating)
    self.nameLabel.text = review.user.nickname
    self.createdAtLabel.text = DateUtils.toReviewFormat(dateString: review.createdAt)
  }
  
  func setRank(rank: Int) {
    for index in 0...stackView.arrangedSubviews.count - 1 {
      if let star = stackView.arrangedSubviews[index] as? UIButton {
        star.isSelected = index < rank
      }
    }
  }
}
