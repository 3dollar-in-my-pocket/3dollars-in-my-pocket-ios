import UIKit

class RegisterCell: BaseCollectionViewCell {
  
  static let registerId = "\(RegisterCell.self)"
  
  let categoryImage = UIImageView()
  
  let titleLabel = UILabel().then {
    $0.textColor = .white
    $0.textAlignment = .center
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
  }
  
  let rankingView = RankingView()
  
  let frontImage = UIImageView().then {
    $0.image = UIImage.init(named: "ic_front_white")
    $0.isHidden = true
  }
  
  let totalLabel = UILabel().then {
    $0.text = "my_page_total".localized
    $0.textColor = UIColor.init(r: 151, g: 151, b: 151)
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.isHidden = true
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor.init(r: 46, g: 46, b: 46)
    self.layer.cornerRadius = 16
    self.addSubViews(categoryImage, titleLabel, rankingView, frontImage, totalLabel)
    self.setupShadow()
  }
  
  override func bindConstraints() {
    self.categoryImage.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(8)
      make.width.height.equalTo(96)
    }
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
      make.top.equalTo(self.categoryImage.snp.bottom).offset(6)
    }
    
    self.rankingView.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalToSuperview().offset(-18)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(9)
      make.height.equalTo(14)
    }
    
    self.frontImage.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(48)
      make.top.equalToSuperview().offset(48)
    }
    
    self.totalLabel.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.frontImage.snp.bottom).offset(4)
    }
  }
  
  func bind(store: Store?) {
    if let store = store {
      self.categoryImage.image = UIImage(named: "img_60_\(store.category.lowcase)")
      self.titleLabel.text = store.storeName
      self.rankingView.setRank(rank: store.rating)
      self.categoryImage.isHidden = false
      self.titleLabel.isHidden = false
      self.rankingView.isHidden = false
      self.frontImage.isHidden = true
      self.totalLabel.isHidden = true
    } else {
      self.categoryImage.isHidden = true
      self.titleLabel.isHidden = true
      self.rankingView.isHidden = true
      self.frontImage.isHidden = false
      self.totalLabel.isHidden = false
    }
  }
  
  private func setupShadow() {
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 10, height: 10)
    self.layer.shadowOpacity = 0.024
  }
}
