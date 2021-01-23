import UIKit

class StoreDetailPhotoCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreDetailPhotoCell.self)"
  
  let photo = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 6
    $0.backgroundColor = UIColor(r: 226, g: 226, b: 226)
  }
  
  let emptyImage = UIImageView().then {
    $0.image = UIImage(named: "img_detail_bungeoppang")
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(photo, emptyImage)
  }
  
  override func bindConstraints() {
    self.photo.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
    }
    
    self.emptyImage.snp.makeConstraints { make in
      make.center.equalTo(self.photo)
      make.width.height.equalTo(42)
    }
  }
  
  func bind(image: Image?) {
    if let image = image {
      self.photo.setImage(urlString: image.url)
      self.emptyImage.isHidden = true
    } else {
      self.emptyImage.isHidden = false
    }
  }
}
