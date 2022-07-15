import UIKit

import Base

class PhotoSubCell: BaseCollectionViewCell {
  
  static let registerId = "\(PhotoSubCell.self)"
  
  let photo = UIImageView().then {
    $0.layer.cornerRadius = 6
    $0.layer.masksToBounds = true
    $0.alpha = 0.6
    $0.contentMode = .scaleAspectFill
  }
  
  
  override func setup() {
    self.addSubViews(photo)
  }
  
  override func bindConstraints() {
    photo.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  func bind(photo: Image) {
    self.photo.setImage(urlString: photo.url)
  }
  
  override var isSelected: Bool {
    didSet {
      self.photo.alpha = isSelected ? 1 : 0.6
      if isSelected {
        self.photo.layer.borderWidth = 2
        self.photo.layer.borderColor = UIColor(r: 255, g: 92, b: 67).cgColor
      } else {
        self.photo.layer.borderWidth = 0
      }
    }
  }
}
