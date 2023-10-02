import UIKit

import Common
import DesignSystem
import Model

final class PhotoDetailCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: UIUtils.windowBounds.width)
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    override func setup() {
        contentView.addSubview(imageView)
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    func bind(_ image: StoreDetailPhoto) {
        self.imageView.setImage(urlString: image.url)
    }
}
