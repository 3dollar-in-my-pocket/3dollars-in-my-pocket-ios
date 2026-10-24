import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class HomeCurationAdCardCell: BaseCollectionViewCell {
    private typealias Layout = HomeCurationStoreCardCell.Layout

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.gray20.color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Colors.gray10.color.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let labelChipStackView = SDLabelChipStackView()

    override func setup() {
        contentView.addSubViews([imageView, titleLabel, subTitleLabel, labelChipStackView])
    }

    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.imageSize)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(Layout.titleTopInset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.titleHeight)
        }

        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.labelRowHeight)
        }

        labelChipStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(Layout.labelRowHeight)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
    }

    func bind(_ card: SDAdCard) {
        imageView.setImage(urlString: card.image?.url)
        titleLabel.setSDText(card.title, customFont: Fonts.bold.font(size: 14))
        titleLabel.lineBreakMode = .byTruncatingTail
        subTitleLabel.setSDText(card.subTitle, customFont: Fonts.medium.font(size: 12))
        subTitleLabel.lineBreakMode = .byTruncatingTail
        labelChipStackView.bind(card.labels)
        accessibilityLabel = titleLabel.text
    }
}
