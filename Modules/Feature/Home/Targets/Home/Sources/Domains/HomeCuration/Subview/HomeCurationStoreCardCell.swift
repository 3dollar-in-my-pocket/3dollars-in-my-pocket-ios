import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class HomeCurationStoreCardCell: BaseCollectionViewCell {
    enum Layout {
        static let width: CGFloat = 100
        static let imageSize: CGFloat = 100
        static let titleTopInset: CGFloat = 8
        static let titleHeight: CGFloat = 20
        static let labelRowHeight: CGFloat = 18
        static let height: CGFloat = imageSize + titleTopInset + titleHeight + labelRowHeight * 2
        static let size = CGSize(width: width, height: height)
    }

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.gray10.color.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let metricStackView = HomeCurationStoreCardCell.makeLabelStackView()
    private let contextStackView = HomeCurationStoreCardCell.makeLabelStackView()

    override func setup() {
        contentView.addSubViews([imageContainerView, titleLabel, metricStackView, contextStackView])
        imageContainerView.addSubview(imageView)
    }

    override func bindConstraints() {
        imageContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.imageSize)
        }

        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Layout.imageSize)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageContainerView.snp.bottom).offset(Layout.titleTopInset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.titleHeight)
        }

        metricStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(Layout.labelRowHeight)
        }

        contextStackView.snp.makeConstraints {
            $0.top.equalTo(metricStackView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(Layout.labelRowHeight)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
        titleLabel.attributedText = nil
        titleLabel.text = nil
        metricStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contextStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func bind(_ card: StoreImagePreviewCard) {
        imageView.setImage(urlString: card.image.url)
        let imageSize = CGSize(
            width: min(card.image.style.width, Layout.imageSize),
            height: min(card.image.style.height, Layout.imageSize)
        )
        imageView.snp.updateConstraints {
            $0.size.equalTo(imageSize)
        }

        titleLabel.setSDText(card.title, customFont: Fonts.semiBold.font(size: 14))
        titleLabel.lineBreakMode = .byTruncatingTail

        setLabels(card.metricLabel, to: metricStackView)
        setLabels(card.contextLabel, to: contextStackView)
        accessibilityLabel = titleLabel.text
    }

    private func setLabels(_ chips: [SDChip], to stackView: UIStackView) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, chip) in chips.enumerated() {
            if index > 0 {
                stackView.addArrangedSubview(makeDivider())
            }
            let chipView = SDChipView(spacing: 2)
            chipView.titleLabel.font = Fonts.medium.font(size: 12)
            chipView.bind(chip)
            stackView.addArrangedSubview(chipView)
        }
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = Colors.gray30.color
        divider.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(8)
        }
        return divider
    }

    private static func makeLabelStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }
}
