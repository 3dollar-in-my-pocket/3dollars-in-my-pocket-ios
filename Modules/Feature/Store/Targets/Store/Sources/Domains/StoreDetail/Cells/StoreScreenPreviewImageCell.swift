import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreScreenPreviewImageCell: BaseCollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = Colors.gray10.color
        return imageView
    }()

    override func setup() {
        contentView.addSubview(imageView)
    }

    override func bindConstraints() {
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
    }

    func bind(_ image: SDImage) {
        imageView.setSDImage(image)
    }
}
