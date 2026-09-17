import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreCouponCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let titleSpacing: CGFloat = 12
        static let cardSpacing: CGFloat = 12
        static let actionButtonHeight: CGFloat = 18
    }

    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let cardsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.cardSpacing
        return stackView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        contentView.addSubViews([titleLabel, actionButton, cardsStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
        }
        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.height.equalTo(Layout.actionButtonHeight)
        }
        cardsStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleSpacing)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
    }

    func bind(_ section: StoreCouponSection) {
        titleLabel.setSDText(section.header?.title)
        actionButton.setOptionalSDButton(section.header?.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header?.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }

        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.cards.forEach { card in
            let cardView = StoreCouponCardView()
            cardView.bind(card)
            cardView.onAction = { [weak self] action in self?.onAction?(action) }
            cardsStack.addArrangedSubview(cardView)
        }
    }
}

private final class StoreCouponCardView: UIView {
    enum Layout {
        static let minContentHeight: CGFloat = 80
        static let badgeOverlap: CGFloat = 18
        static let badgeHeight: CGFloat = 26
        static let iconSize: CGFloat = 30
        static let iconTrailingInset: CGFloat = 25
        static let dividerSpacing: CGFloat = 16
        static let dividerVerticalInset: CGFloat = 12
        static let textInset: CGFloat = 12
        static let textLeadingInset: CGFloat = 18
        static let dividerColor = UIColor(hex: "#BC4BD6") ?? Colors.mainPink.color
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let containerView = UIView()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.couponBackground.image
        return imageView
    }()

    private let textStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private let titleLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let dateLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.regular.font(size: 14))
        label.numberOfLines = 1
        return label
    }()

    private let dividerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.couponDot.image.withTintColor(Layout.dividerColor)
        return imageView
    }()

    private let trailingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    private let rightAreaButton = UIButton(type: .custom)

    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 8, rightInset: 8)
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.mainPink.color
        label.backgroundColor = Colors.gray90.color
        label.layer.cornerRadius = Layout.badgeHeight / 2
        label.clipsToBounds = true
        return label
    }()

    private var containerTopConstraint: Constraint?
    private var action: StoreSectionAction?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        bindConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = .clear
        addSubViews([containerView, badgeLabel])
        containerView.addSubViews([backgroundImageView, textStack, dividerImageView, trailingButton, rightAreaButton])
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(dateLabel)
        dividerImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }

    private func bindConstraints() {
        containerView.snp.makeConstraints {
            containerTopConstraint = $0.top.equalToSuperview().offset(Layout.badgeOverlap).constraint
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(Layout.minContentHeight)
        }
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        badgeLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(12)
            $0.bottom.equalTo(containerView.snp.top).offset(8)
            $0.height.equalTo(Layout.badgeHeight)
        }
        trailingButton.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(Layout.iconSize)
            $0.height.greaterThanOrEqualTo(Layout.iconSize)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Layout.iconTrailingInset)
        }
        dividerImageView.snp.makeConstraints {
            $0.trailing.equalTo(trailingButton.snp.leading).offset(-Layout.dividerSpacing)
            $0.top.bottom.equalToSuperview().inset(Layout.dividerVerticalInset)
            $0.width.equalTo(1)
        }
        rightAreaButton.snp.makeConstraints {
            $0.leading.equalTo(dividerImageView.snp.trailing)
            $0.top.bottom.trailing.equalToSuperview()
        }
        textStack.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().inset(Layout.textInset)
            $0.leading.equalToSuperview().inset(Layout.textLeadingInset)
            $0.trailing.equalTo(dividerImageView.snp.leading).offset(-Layout.dividerSpacing)
            $0.bottom.lessThanOrEqualToSuperview().inset(Layout.textInset)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupActions() {
        rightAreaButton.addAction(UIAction { [weak self] _ in self?.didTapRightArea() }, for: .touchUpInside)
        trailingButton.isUserInteractionEnabled = false
    }

    func bind(_ card: StoreCouponCard) {
        titleLabel.setSDText(card.title, lineHeight: 24)
        dateLabel.setSDText(card.subTitle, lineHeight: 20)
        trailingButton.setSDButton(card.trailingButton)
        trailingButton.backgroundColor = .clear

        if let badgeText = card.badge?.text {
            badgeLabel.setSDText(badgeText)
            badgeLabel.isHidden = false
            containerTopConstraint?.update(offset: Layout.badgeOverlap)
        } else {
            badgeLabel.isHidden = true
            containerTopConstraint?.update(offset: 0)
        }

        action = card.trailingButton.storeSectionAction
            ?? card.clickLog.map { .custom(SDCustomAction(actionType: .unknown), clickLog: $0) }
        rightAreaButton.isHidden = action == nil
    }

    private func didTapRightArea() {
        guard let action else { return }
        onAction?(action)
    }
}
