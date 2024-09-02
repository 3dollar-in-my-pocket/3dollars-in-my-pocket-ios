import UIKit

import Common

final class BossStoreInfoPhotoItemCell: BaseCollectionViewCell {
    enum Layout {
        static let width: CGFloat = UIUtils.windowBounds.width - 87
        static let ratio: CGFloat = 0.62
        static let size = CGSize(width: width, height: width * ratio)
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.clear()
    }
    
    override func setup() {
        imageView.backgroundColor = Colors.gray10.color
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(imageUrl: String) {
        imageView.setImage(urlString: imageUrl)
    }
}
