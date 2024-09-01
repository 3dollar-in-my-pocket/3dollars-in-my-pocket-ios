import UIKit

import Common
import Model

final class BossStorePhotoItemCell: BaseCollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
    
    func bind(imageResponse: ImageResponse) {
        imageView.setImage(urlString: imageResponse.imageUrl)
    }
}
