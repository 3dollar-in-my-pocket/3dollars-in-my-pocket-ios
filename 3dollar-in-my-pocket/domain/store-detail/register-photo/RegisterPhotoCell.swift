import UIKit
import Photos
import RxSwift

class RegisterPhotoCell: BaseCollectionViewCell {
  
  static let registerId = "\(RegisterPhotoCell.self)"
  var imageRequestId: PHImageRequestID?
  
  let photo = UIImageView().then {
    $0.backgroundColor = .gray
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 2
    $0.layer.masksToBounds = true
  }
  
  let dimView = UIView().then {
    $0.backgroundColor = UIColor(r: 28, g: 28, b: 28, a: 0.3)
    $0.layer.cornerRadius = 2
    $0.isHidden = true
  }
  
  let checkBox = UIImageView().then {
    $0.image = UIImage(named: "ic_check_circle_off")
  }
  
  override func prepareForReuse() {
    if let imageRequestId = self.imageRequestId {
      PHImageManager.default().cancelImageRequest(imageRequestId)
    }
    super.prepareForReuse()
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews(photo, dimView, checkBox)
  }
  
  override func bindConstraints() {
    self.photo.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
    }
    
    self.dimView.snp.makeConstraints { make in
      make.edges.equalTo(self.photo)
    }
    
    self.checkBox.snp.makeConstraints { make in
      make.top.equalTo(self.photo).offset(8)
      make.right.equalTo(self.photo).offset(-8)
      make.width.height.equalTo(20)
    }
  }
  
  func bind(asset: PHAsset) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true

    self.imageRequestId = PHImageManager.default().requestImage(
      for: asset,
      targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
      contentMode: .aspectFit,
      options: options) { (image, _) in
      guard let image = image else { return }
      self.photo.image = image
    }
  }
  
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        self.dimView.layer.borderWidth = 2
        self.dimView.layer.borderColor = UIColor(r: 255, g: 161, b: 170).cgColor
        self.checkBox.image = UIImage(named: "ic_check_circle_on")
      } else {
        self.checkBox.image = UIImage(named: "ic_check_circle_off")
      }
      self.dimView.isHidden = !isSelected
    }
  }
}
