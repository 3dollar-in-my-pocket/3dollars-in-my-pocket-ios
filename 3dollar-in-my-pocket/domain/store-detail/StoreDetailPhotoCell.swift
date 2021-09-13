import UIKit

class StoreDetailPhotoCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreDetailPhotoCell.self)"
  
  let photo = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 6
    $0.layer.masksToBounds = true
    $0.backgroundColor = UIColor(r: 226, g: 226, b: 226)
  }
  
  let emptyImage = UIImageView().then {
    $0.image = UIImage(named: "img_detail_bungeoppang")
  }
  
  let dimView = UIView().then {
    $0.backgroundColor = UIColor(r: 17, g: 17, b: 17, a: 0.35)
    $0.layer.cornerRadius = 6
    $0.layer.masksToBounds = true
    $0.isHidden = true
  }
  
  let countLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
    $0.textColor = UIColor(r: 255, g: 161, b: 170)
    $0.isHidden = true
  }
  
  let moreLabel = UILabel().then {
    $0.text = "store_detail_more_photo".localized
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.isHidden = true
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.photo.image = nil
    self.dimView.isHidden = true
    self.countLabel.isHidden = true
    self.moreLabel.isHidden = true
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(
      photo, emptyImage, dimView, countLabel,
      moreLabel
    )
  }
  
  override func bindConstraints() {
    self.photo.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
    }
    
    self.emptyImage.snp.makeConstraints { make in
      make.center.equalTo(self.photo)
      make.width.height.equalTo(42)
    }
    
    self.dimView.snp.makeConstraints { make in
      make.edges.equalTo(photo)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-8)
    }
    
    self.moreLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(8)
    }
  }
  
  func bind(image: Image?, isLast: Bool, count: Int) {
    if let image = image {
      self.photo.setImage(urlString: image.url)
      self.emptyImage.isHidden = true
    } else {
      self.emptyImage.isHidden = false
    }
    self.dimView.isHidden = !isLast || count == 3
    self.countLabel.isHidden = !isLast || count == 3
    self.moreLabel.isHidden = !isLast || count == 3
    if isLast {
      self.countLabel.text =  "+\(count - 3)"
    }
  }
}
