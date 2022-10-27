import UIKit

import Base

final class PhotoMainCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(PhotoMainCollectionViewCell.self)"
    static let itemSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
    )
    static let imageSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.width
    )
    
    private let scrollView = UIScrollView().then {
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 2.0
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
    }
    
    private let containerView = UIView()
    
    private let photo = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.contentView.isUserInteractionEnabled = false
        self.scrollView.delegate = self
        self.containerView.addSubViews(self.photo)
        self.scrollView.addSubViews(self.containerView)
        self.addSubview(self.scrollView)
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

extension PhotoMainCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photo
    }
}
