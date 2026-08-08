import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreAppearanceDayCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let rowsStack = UIStackView()

    override func prepareForReuse() {
        super.prepareForReuse()
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        rowsStack.axis = .vertical
        rowsStack.spacing = 6
        contentView.addSubViews([titleLabel, rowsStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        rowsStack.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(12); $0.leading.trailing.bottom.equalToSuperview() }
    }

    func bind(_ section: StoreAppearanceDaySection) {
        titleLabel.setSDText(section.header.title)
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.items.forEach { rowsStack.addArrangedSubview(StoreAppearanceDayRowView(item: $0)) }
    }
}

private final class StoreAppearanceDayRowView: UIView {
    private let leadingLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
    private let primaryLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
    private let secondaryLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))

    init(item: StoreAppearanceDayItem) {
        super.init(frame: .zero)
        layer.cornerRadius = 8
        addSubViews([leadingLabel, primaryLabel, secondaryLabel])
        leadingLabel.snp.makeConstraints { $0.top.bottom.leading.equalToSuperview().inset(10); $0.width.equalTo(34) }
        primaryLabel.snp.makeConstraints { $0.centerY.equalTo(leadingLabel); $0.leading.equalTo(leadingLabel.snp.trailing).offset(8) }
        secondaryLabel.snp.makeConstraints { $0.centerY.equalTo(leadingLabel); $0.leading.equalTo(primaryLabel.snp.trailing).offset(8); $0.trailing.lessThanOrEqualToSuperview().inset(10) }
        setSDSurfaceStyle(item.style)
        leadingLabel.setSDText(item.leadingText)
        primaryLabel.setSDText(item.primaryText)
        secondaryLabel.setSDText(item.secondaryText)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
