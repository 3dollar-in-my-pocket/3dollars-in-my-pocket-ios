import UIKit

class StoreDetailPhotoCell: BaseCollectionViewCell {
  
  static let registerId = "\(StoreDetailPhotoCell.self)"
  
  let photo = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 6
    $0.backgroundColor = .gray
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(photo)
  }
  
  override func bindConstraints() {
    self.photo.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
    }
  }
  
  func bind(url: String) {
    self.photo.setImage(urlString: url)
  }
}
