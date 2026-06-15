import UIKit

import Common
import DesignSystem
import Model

final class StorePreviewImageCell: BaseCollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
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
