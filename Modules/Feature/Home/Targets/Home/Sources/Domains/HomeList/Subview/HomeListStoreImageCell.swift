import UIKit

import Common
import DesignSystem
import Model

import Kingfisher

final class HomeListStoreImageCell: BaseCollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Colors.gray10.color
        return imageView
    }()

    override func setup() {
        contentView.addSubview(imageView)
    }

    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }

    func bind(_ image: SDImage) {
        imageView.setImage(urlString: image.url)
    }
}
