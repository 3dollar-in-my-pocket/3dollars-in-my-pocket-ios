import UIKit
import GoogleMobileAds

class StoreDetailReviewCell: BaseTableViewCell {
  
  static let registerId = "\(StoreDetailReviewCell.self)"
  
  let adBannerView = GADBannerView().then {
    $0.isHidden = true
  }
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
    $0.layer.masksToBounds = true
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
    $0.isHidden = true
  }
  
  let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 12)
  }
  
  let createdAtLabel = UILabel().then {
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "SpoqaHanSans-Regular", size: 12)
  }
  
  let replyLabel = UILabel().then {
    $0.textColor = UIColor(r: 46, g: 46, b: 46)
    $0.numberOfLines = 0
    $0.font = UIFont(name: "SpoqaHanSans-Regular", size: 14)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.moreButton.isHidden = true
  }
  
  
  override func setup() {
    stackView.addArrangedSubview(star1)
    stackView.addArrangedSubview(star2)
    stackView.addArrangedSubview(star3)
    stackView.addArrangedSubview(star4)
    stackView.addArrangedSubview(star5)
    addSubViews(
      containerView, adBannerView, stackView, moreButton,
      nameLabel, createdAtLabel, replyLabel
    )
    selectionStyle = .none
    contentView.isUserInteractionEnabled = false
    backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
  override func bindConstraints() {
    containerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(8)
      make.bottom.equalTo(replyLabel).offset(16)
      make.bottom.equalToSuperview()
    }
    
    adBannerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.bottom.equalToSuperview().offset(13)
    }
    
    star1.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    star2.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    star3.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    star4.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    star5.snp.makeConstraints { (make) in
      make.width.height.equalTo(18)
    }
    
    stackView.snp.makeConstraints { (make) in
      make.left.equalTo(containerView).offset(16)
      make.height.equalTo(16)
      make.top.equalTo(containerView).offset(16)
    }
    
    moreButton.snp.makeConstraints { make in
      make.right.equalTo(containerView).offset(-12)
      make.top.equalTo(containerView).offset(24)
      make.width.height.equalTo(24)
    }
    
    nameLabel.snp.makeConstraints { (make) in
      make.left.equalTo(stackView)
      make.top.equalTo(stackView.snp.bottom).offset(6)
    }
    
    createdAtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(nameLabel)
      make.left.equalTo(nameLabel.snp.right).offset(8)
    }
    
    replyLabel.snp.makeConstraints { (make) in
      make.left.equalTo(nameLabel)
      make.right.equalTo(containerView).offset(-16)
      make.top.equalTo(nameLabel.snp.bottom).offset(8)
    }
  }
  
  func bind(review: Review?) {
    if let review = review {
      self.setRank(rank: review.rating)
      self.nameLabel.text = review.user.nickname
      self.replyLabel.text = review.contents
      self.createdAtLabel.text = DateUtils.toReviewFormat(dateString: review.createdAt)
      self.adBannerView.isHidden = true
      self.stackView.isHidden = false
      self.replyLabel.isHidden = false
      self.createdAtLabel.isHidden = false
      self.nameLabel.isHidden = false
      self.containerView.isHidden = false
    } else {
      self.containerView.isHidden = true
      self.adBannerView.isHidden = false
      self.stackView.isHidden = true
      self.replyLabel.isHidden = true
      self.createdAtLabel.isHidden = true
      self.nameLabel.isHidden = true
    }
  }
  
  func setRank(rank: Int) {
    for index in 0...stackView.arrangedSubviews.count - 1 {
      if let star = stackView.arrangedSubviews[index] as? UIButton {
        star.isSelected = index < rank
      }
    }
  }
}
