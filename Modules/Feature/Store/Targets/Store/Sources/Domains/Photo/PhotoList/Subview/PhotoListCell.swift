import UIKit

import Common
import DesignSystem
import Model

final class PhotoListCell: BaseCollectionViewCell {
    enum Layout {
        static let itemSpace: CGFloat = 16
        static let numberOfItemInRow: CGFloat = 2
        static let width: CGFloat = (UIUtils.windowBounds.width - 40 - itemSpace) / numberOfItemInRow
        static let size = CGSize(width: width, height: width)
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = Colors.gray20.color
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    override func setup() {
        contentView.addSubViews([
            imageView
        ])
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ photo: StoreDetailPhoto) {
        imageView.setImage(urlString: photo.url)
    }
}
