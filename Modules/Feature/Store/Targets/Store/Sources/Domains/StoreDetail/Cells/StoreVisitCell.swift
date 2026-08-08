import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreVisitCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let summaryStack = StoreSectionFlowStackView(spacing: 8)
    private let historyView = UIView()
    private let historyStack = StoreSectionFlowStackView(spacing: 6)
    private let moreLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))

    override func prepareForReuse() {
        super.prepareForReuse()
        summaryStack.removeAll()
        historyStack.removeAll()
        onAction = nil
    }

    override func setup() {
        historyView.layer.cornerRadius = 12
        historyView.addSubViews([historyStack, moreLabel])
        contentView.addSubViews([titleLabel, summaryStack, historyView])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        summaryStack.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(12); $0.leading.trailing.equalToSuperview() }
        historyView.snp.makeConstraints { $0.top.equalTo(summaryStack.snp.bottom).offset(8); $0.leading.trailing.bottom.equalToSuperview() }
        historyStack.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview().inset(14) }
        moreLabel.snp.makeConstraints { $0.top.equalTo(historyStack.snp.bottom).offset(6); $0.leading.trailing.bottom.equalToSuperview().inset(14) }
    }

    func bind(_ section: StoreVisitSection) {
        titleLabel.setSDText(section.header.title)
        summaryStack.bind(section.summary.chips)
        historyView.setSDSurfaceStyle(section.history.style)
        historyStack.bind(section.history.items)
        moreLabel.setSDText(section.history.moreText)
        moreLabel.isHidden = section.history.moreText == nil
    }
}
