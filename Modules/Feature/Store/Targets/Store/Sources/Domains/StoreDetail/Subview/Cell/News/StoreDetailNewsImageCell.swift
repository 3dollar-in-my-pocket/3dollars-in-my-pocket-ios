import UIKit

import Common
import Model

final class StoreDetailNewsImageCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 208
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.gray70.color
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Colors.gray20.color.cgColor
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.clear()
    }
    
    override func setup() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(sdImage: SDImage) {
        imageView.setImage(urlString: sdImage.url)
    }
}
