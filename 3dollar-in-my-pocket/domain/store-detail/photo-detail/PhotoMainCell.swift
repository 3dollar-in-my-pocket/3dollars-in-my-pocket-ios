import UIKit

import Base

class PhotoMainCell: BaseCollectionViewCell {
  
  static let registerId = "\(PhotoMainCell.self)"
  
  let scrollView = UIScrollView().then {
    $0.minimumZoomScale = 1.0
    $0.maximumZoomScale = 2.0
    $0.alwaysBounceVertical = false
    $0.alwaysBounceHorizontal = false
  }
  
  let containerView = UIView()
  
  let photo = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.contentView.isUserInteractionEnabled = false
    self.scrollView.delegate = self
    self.containerView.addSubViews(photo)
    self.scrollView.addSubViews(containerView)
    self.addSubview(scrollView)
  }
  
  override func bindConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalTo(0)
      make.top.bottom.left.right.equalToSuperview()
    }
    
    self.photo.snp.makeConstraints { (make) in
      make.width.height.equalTo(UIScreen.main.bounds.width)
      make.centerY.equalTo(self.scrollView)
      make.left.equalToSuperview()
    }
  }
  
  func bind(photo: Image) {
    self.photo.setImage(urlString: photo.url)
  }
}

extension PhotoMainCell: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.photo
  }
}
