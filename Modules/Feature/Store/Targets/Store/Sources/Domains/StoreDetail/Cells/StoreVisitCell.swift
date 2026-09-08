import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreVisitCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let summaryChipHeight: CGFloat = 48
        static let historyCornerRadius: CGFloat = 20
        static let emptyBannerHeight: CGFloat = 112
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 0, left: Layout.horizontalMargin, bottom: 0, right: Layout.horizontalMargin)
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.numberOfLines = 1
        label.textColor = Colors.gray100.color
        return label
    }()

    private let summaryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let historyView = UIView()

    private let historyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()

    private let moreLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.numberOfLines = 1
        label.font = Fonts.medium.font(size: 12)
        return label
    }()

    private let emptyBannerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray100.color
        view.layer.cornerRadius = Layout.historyCornerRadius
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let emptyBannerTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = StoreVisitCell.makeEmptyBannerTitle()
        label.textAlignment = .center
        return label
    }()

    private let emptyBannerDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.StoreDetail.Visit.Empty.description
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        summaryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        historyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        historyView.layer.cornerRadius = Layout.historyCornerRadius
        historyView.clipsToBounds = true
        historyView.addSubViews([historyStack, moreLabel])
        emptyBannerView.addSubViews([emptyBannerTitleLabel, emptyBannerDescriptionLabel])

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(summaryStack, previousSpace: 12)
        contentStack.addArrangedSubview(historyView, previousSpace: 8)
        contentStack.addArrangedSubview(emptyBannerView, previousSpace: 8)
        contentView.addSubview(contentStack)
    }

    override func bindConstraints() {
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        historyStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        moreLabel.snp.makeConstraints {
            $0.top.equalTo(historyStack.snp.bottom).offset(4)
            // 방문 내역 행의 불릿(4pt) + 간격(8pt) 뒤 텍스트 시작점과 정렬한다.
            $0.leading.equalToSuperview().offset(28)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
        emptyBannerView.snp.makeConstraints {
            $0.height.equalTo(Layout.emptyBannerHeight)
        }
        emptyBannerTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        emptyBannerDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(emptyBannerTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    func bind(_ section: StoreVisitSection) {
        let isEmpty = section.history.items.isEmpty
        if isEmpty {
            titleLabel.text = Strings.StoreDetail.Visit.Header.titleEmpty
        } else {
            titleLabel.setSDText(section.header.title)
        }

        summaryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.summary.chips.forEach { chip in
            summaryStack.addArrangedSubview(makeSummaryChipView(chip))
        }

        historyView.isHidden = isEmpty
        emptyBannerView.isHidden = isEmpty.isNot
        guard isEmpty.isNot else { return }

        historyView.setSDSurfaceStyle(section.history.style)
        historyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.history.items.forEach { item in
            let chipView = SDChipView(spacing: 8)
            chipView.bind(item)
            historyStack.addArrangedSubview(chipView)
        }
        moreLabel.setSDText(section.history.moreText)
        moreLabel.isHidden = section.history.moreText == nil
    }

    private func makeSummaryChipView(_ chip: SDChip) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = Layout.summaryChipHeight / 2
        container.clipsToBounds = true
        if let style = chip.style {
            container.setSDChipStyle(style)
        }

        let chipView = SDChipView(spacing: 8)
        chipView.bind(chip)
        container.addSubview(chipView)
        chipView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        container.snp.makeConstraints {
            $0.height.equalTo(Layout.summaryChipHeight)
        }
        return container
    }

    private static func makeEmptyBannerTitle() -> NSAttributedString {
        let title = Strings.StoreDetail.Visit.Empty.title
        let attributedTitle = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: Fonts.bold.font(size: 16) as Any,
                .foregroundColor: Colors.gray0.color
            ]
        )
        if let highlightRange = title.range(of: "가게의 최근 활동") {
            attributedTitle.addAttribute(
                .foregroundColor,
                value: Colors.mainPink.color,
                range: NSRange(highlightRange, in: title)
            )
        }
        return attributedTitle
    }
}
