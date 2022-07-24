import UIKit

import Base

class PhotoListCell: BaseCollectionViewCell {
  
  static let registerId = "\(PhotoListCell.self)"
  
  let photo = UIImageView().then{
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 2
    $0.layer.masksToBounds = true
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(photo)
  }
  
  override func bindConstraints() {
    self.photo.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }
  }
  
  func bind(photo: Image) {
    self.photo.setImage(urlString: photo.url)
  }
}
