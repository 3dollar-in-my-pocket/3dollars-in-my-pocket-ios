import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreCouponCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let cardView = UIView()
    private let badgeLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
    private let cardTitleLabel = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 15))
    private let subtitleLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
    private let trailingButton = UIButton(type: .system)

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
    }

    override func setup() {
        cardView.layer.cornerRadius = 12
        cardView.addSubViews([badgeLabel, cardTitleLabel, subtitleLabel, trailingButton])
        contentView.addSubViews([titleLabel, actionButton, cardView])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        actionButton.snp.makeConstraints { $0.top.trailing.equalToSuperview() }
        cardView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(94)
        }
        badgeLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(14)
        }
        cardTitleLabel.snp.makeConstraints {
            $0.top.equalTo(badgeLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(14)
            $0.trailing.lessThanOrEqualTo(trailingButton.snp.leading).offset(-8)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(cardTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(14)
        }
        trailingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }

    func bind(_ section: StoreCouponSection) {
        titleLabel.setSDText(section.header?.title)
        actionButton.setOptionalSDButton(section.header?.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        trailingButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header?.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        guard let card = section.cards.first else { cardView.isHidden = true; return }
        cardView.isHidden = false
        cardView.setSDSurfaceStyle(card.style)
        if let badge = card.badge {
            badgeLabel.setSDChip(badge)
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
        cardTitleLabel.setSDText(card.title)
        subtitleLabel.setSDText(card.subTitle)
        trailingButton.setSDButton(card.trailingButton)
        if let action = card.trailingButton.storeSectionAction {
            trailingButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        } else if let clickLog = card.clickLog {
            let action = StoreSectionAction.custom(.init(actionType: .unknown), clickLog: clickLog)
            trailingButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}
