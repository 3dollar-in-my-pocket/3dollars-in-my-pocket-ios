import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreAppearanceDayCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let titleSpacing: CGFloat = 12
        static let cardCornerRadius: CGFloat = 20
        static let cardInset: CGFloat = 16
        static let rowSpacing: CGFloat = 12
        static let dividerHeight: CGFloat = 1
    }

    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = Layout.cardCornerRadius
        return view
    }()
    private let rowsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.rowSpacing
        return stackView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        contentView.addSubViews([titleLabel, cardView])
        cardView.addSubview(rowsStack)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalMargin)
        }
        cardView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleSpacing)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
        rowsStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.cardInset)
        }
    }

    func bind(_ section: StoreAppearanceDaySection) {
        titleLabel.setSDText(section.header.title, lineHeight: 24)
        cardView.setSDSurfaceStyle(section.items.first?.style)

        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in section.items.enumerated() {
            if index > 0 {
                rowsStack.addArrangedSubview(makeDivider())
            }
            rowsStack.addArrangedSubview(StoreAppearanceDayRowView(item: item))
        }
    }

    private func makeDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = Colors.gray30.color
        view.snp.makeConstraints { $0.height.equalTo(Layout.dividerHeight) }
        return view
    }
}

private final class StoreAppearanceDayRowView: UIView {
    private enum Layout {
        static let leadingWidth: CGFloat = 48
        static let columnSpacing: CGFloat = 12
        static let textSpacing: CGFloat = 2
    }

    private let leadingLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 14))
        label.numberOfLines = 1
        return label
    }()

    private let primaryLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 14))
        label.textAlignment = .right
        return label
    }()

    private let secondaryLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        label.textAlignment = .right
        return label
    }()

    init(item: StoreAppearanceDayItem) {
        super.init(frame: .zero)

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = Layout.textSpacing
        textStack.addArrangedSubview(primaryLabel)
        textStack.addArrangedSubview(secondaryLabel)

        addSubViews([leadingLabel, textStack])
        leadingLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.width.equalTo(Layout.leadingWidth)
        }
        textStack.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(leadingLabel.snp.trailing).offset(Layout.columnSpacing)
        }

        leadingLabel.setSDText(item.leadingText, lineHeight: 20)
        primaryLabel.setSDText(item.primaryText, lineHeight: 20)
        secondaryLabel.setSDText(item.secondaryText, lineHeight: 18)
        secondaryLabel.isHidden = item.secondaryText == nil
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
