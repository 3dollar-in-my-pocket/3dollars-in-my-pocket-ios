import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreScreenPreviewActionCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 36
        static let imagePadding: CGFloat = 4

        static func size(for actionBar: SDActionBar) -> CGSize {
            let sizingButton = makeButton()
            sizingButton.setSDButton(actionBar.button)
            var width = sizingButton.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
            if let image = actionBar.button.image {
                width += image.style.width + imagePadding
            }

            return CGSize(width: ceil(width), height: height)
        }
    }

    static func makeButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.imagePadding = Layout.imagePadding
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        return button
    }

    private let button: UIButton = {
        let button = StoreScreenPreviewActionCell.makeButton()
        button.isUserInteractionEnabled = false
        return button
    }()

    override func setup() {
        contentView.addSubview(button)
    }

    override func bindConstraints() {
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        button.clear()
    }

    func bind(_ sdButton: SDButton) {
        button.setSDButton(sdButton)
    }
}
