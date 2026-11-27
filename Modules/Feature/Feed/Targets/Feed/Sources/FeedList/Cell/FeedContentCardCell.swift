import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class FeedContentCardCell: BaseCollectionViewCell {
    @MainActor
    enum Layout {
        static let contentInset: CGFloat = 16
        static let headerSpacing: CGFloat = 16
        static let bodySpacing: CGFloat = 12
        static let badgeHeight: CGFloat = 26
        static let leadingImageSize: CGFloat = 60
        static let overlineHeight: CGFloat = 18
        static let titleHeight: CGFloat = 24
        static let metadataHeight: CGFloat = 18

        private static let sizingCell = FeedContentCardCell(frame: .zero)

        static func height(card: HomeNewsContentCard, cellWidth: CGFloat) -> CGFloat {
            sizingCell.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 1000)
            sizingCell.bind(card: card, cellWidth: cellWidth)
            let size = sizingCell.contentView.systemLayoutSizeFitting(
                CGSize(width: cellWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return ceil(size.height)
        }
    }

    var onTapImage: ((_ blockIndex: Int, _ imageIndex: Int) -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.layoutMargins = UIEdgeInsets(
            top: Layout.contentInset,
            left: Layout.contentInset,
            bottom: Layout.contentInset,
            right: Layout.contentInset
        )
        return stackView
    }()

    private let headerView = UIView()

    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 12, rightInset: 12)
        label.layer.cornerRadius = Layout.badgeHeight / 2
        label.layer.masksToBounds = true
        label.font = Fonts.bold.font(size: 12)
        return label
    }()

    private let trailingLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray40.color
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let summaryView = UIView()

    private let leadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let summaryTextStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    private let overlineLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray40.color
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let metadataStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private var bodyBlockViews: [FeedContentBodyBlockView] = []

    override func prepareForReuse() {
        super.prepareForReuse()
        leadingImageView.clear()
        onTapImage = nil
    }

    override func setup() {
        contentView.backgroundColor = Colors.systemWhite.color
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = Colors.systemBlack.color.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 4

        contentView.addSubview(stackView)
        headerView.addSubViews([badgeLabel, trailingLabel])
        summaryView.addSubViews([leadingImageView, summaryTextStackView])
        summaryTextStackView.addArrangedSubview(overlineLabel)
        summaryTextStackView.addArrangedSubview(titleLabel)
        summaryTextStackView.setCustomSpacing(4, after: titleLabel)
        summaryTextStackView.addArrangedSubview(metadataStackView)
        stackView.addArrangedSubview(headerView)
        stackView.setCustomSpacing(Layout.headerSpacing, after: headerView)
        stackView.addArrangedSubview(summaryView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        headerView.snp.makeConstraints {
            $0.height.equalTo(Layout.badgeHeight)
        }

        badgeLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(trailingLabel.snp.leading).offset(-12)
        }

        trailingLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }

        summaryView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(Layout.leadingImageSize)
            $0.height.equalTo(0).priority(.low)
        }

        leadingImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(Layout.leadingImageSize)
        }

        summaryTextStackView.snp.makeConstraints {
            $0.leading.equalTo(leadingImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }

        overlineLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.overlineHeight)
        }

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.titleHeight)
        }

        metadataStackView.snp.makeConstraints {
            $0.height.equalTo(Layout.metadataHeight)
        }
    }

    func bind(card: HomeNewsContentCard, cellWidth: CGFloat) {
        bindHeader(card.header)
        bindSummary(card.header.summary)
        bindBodyBlocks(card.bodyBlocks)
    }

    private func bindHeader(_ header: HomeNewsContentCardHeader) {
        badgeLabel.isHidden = header.badge == nil
        badgeLabel.backgroundColor = .clear
        if let badge = header.badge {
            badgeLabel.setSDChip(badge)
        }
        trailingLabel.setSDText(header.trailingText)
        headerView.isHidden = header.badge == nil && header.trailingText == nil
        stackView.setCustomSpacing(headerView.isHidden ? 0 : Layout.headerSpacing, after: headerView)
    }

    private func bindSummary(_ summary: HomeNewsCardSummary) {
        leadingImageView.setImage(urlString: summary.leadingImage?.url)
        overlineLabel.setSDText(summary.overline)
        overlineLabel.isHidden = (overlineLabel.attributedText?.string ?? overlineLabel.text ?? "").isEmpty
        titleLabel.setSDText(summary.title)
        bindMetadata(summary.metadata)
    }

    private func bindMetadata(_ chips: [SDChip]) {
        metadataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, chip) in chips.enumerated() {
            if index > 0 {
                metadataStackView.addArrangedSubview(makeDivider())
            }
            let chipView = SDChipView(spacing: 2)
            chipView.titleLabel.font = Fonts.medium.font(size: 12)
            chipView.bind(chip)
            metadataStackView.addArrangedSubview(chipView)
        }
        metadataStackView.isHidden = chips.isEmpty
    }

    private func bindBodyBlocks(_ blocks: [HomeNewsBodyBlock]) {
        bodyBlockViews.forEach { $0.removeFromSuperview() }
        bodyBlockViews = blocks.enumerated().map { blockIndex, block in
            let blockView = FeedContentBodyBlockView()
            blockView.bind(block: block)
            blockView.onTapImage = { [weak self] imageIndex in
                self?.onTapImage?(blockIndex, imageIndex)
            }
            return blockView
        }

        var previousView: UIView = summaryView
        for blockView in bodyBlockViews {
            stackView.addArrangedSubview(blockView)
            stackView.setCustomSpacing(Layout.bodySpacing, after: previousView)
            previousView = blockView
        }
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = Colors.gray20.color
        divider.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(8)
        }
        return divider
    }
}
