import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class HomeListAdCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalInset: CGFloat = 16
        static let horizontalInset: CGFloat = 20
        static let titleHeight: CGFloat = 24
        static let subTitleHeight: CGFloat = 18
        static let subTitleSpacing: CGFloat = 4
        static let imageHeight: CGFloat = 120
        static let imageSpacing: CGFloat = 12

        static func height(_ card: SDAdCard) -> CGFloat {
            let hasHeader = card.title != nil || card.labels.isNotEmpty
            var height = verticalInset * 2
            if hasHeader {
                height += titleHeight
            }
            if card.subTitle != nil {
                height += (hasHeader ? subTitleSpacing : 0) + subTitleHeight
            }
            if card.image != nil {
                let hasText = hasHeader || card.subTitle != nil
                height += (hasText ? imageSpacing : 0) + imageHeight
            }
            return height
        }
    }

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.layoutMargins = .init(
            top: Layout.verticalInset,
            left: Layout.horizontalInset,
            bottom: Layout.verticalInset,
            right: Layout.horizontalInset
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        return stackView
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let labelChipStackView = SDLabelChipStackView()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.numberOfLines = 1
        return label
    }()

    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Colors.gray10.color.cgColor
        imageView.backgroundColor = Colors.gray20.color
        return imageView
    }()

    private let bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        return view
    }()

    override func setup() {
        contentView.addSubview(contentStackView)
        contentView.addSubview(bottomBorderView)

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(labelChipStackView)
        headerStackView.addArrangedSubview(UIView())

        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(subTitleLabel, previousSpace: Layout.subTitleSpacing)
        contentStackView.addArrangedSubview(bannerImageView, previousSpace: Layout.imageSpacing)
    }

    override func bindConstraints() {
        contentStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        headerStackView.snp.makeConstraints {
            $0.height.equalTo(Layout.titleHeight)
        }

        subTitleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.subTitleHeight)
        }

        bannerImageView.snp.makeConstraints {
            $0.height.equalTo(Layout.imageHeight)
        }

        bottomBorderView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bannerImageView.clear()
    }

    func bind(_ card: SDAdCard) {
        titleLabel.setSDText(card.title, customFont: Fonts.bold.font(size: 16))
        titleLabel.isHidden = card.title == nil
        labelChipStackView.bind(card.labels)
        headerStackView.isHidden = card.title == nil && card.labels.isEmpty

        subTitleLabel.setSDText(card.subTitle, customFont: Fonts.medium.font(size: 12))
        subTitleLabel.isHidden = card.subTitle == nil
        contentStackView.setCustomSpacing(
            card.subTitle == nil ? Layout.imageSpacing : Layout.subTitleSpacing,
            after: headerStackView
        )

        bannerImageView.isHidden = card.image == nil
        bannerImageView.setImage(urlString: card.image?.url)
    }
}
