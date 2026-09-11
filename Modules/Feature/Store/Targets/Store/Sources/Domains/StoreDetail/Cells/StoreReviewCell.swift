import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreReviewCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let cardCornerRadius: CGFloat = 20
        static let cardInset: CGFloat = 16
    }

    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let summaryView = StoreReviewSummaryView()
    private let cardsStack = UIStackView()
    private let moreButton = UIButton(type: .system)

    override func prepareForReuse() {
        super.prepareForReuse()
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        cardsStack.axis = .vertical
        cardsStack.spacing = 8
        contentView.addSubViews([titleLabel, actionButton, summaryView, cardsStack, moreButton])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }
        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
        summaryView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
        cardsStack.snp.makeConstraints {
            $0.top.equalTo(summaryView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(summaryView)
        }
        moreButton.snp.makeConstraints {
            $0.top.equalTo(cardsStack.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(summaryView)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
    }

    func bind(_ section: StoreReviewSection) {
        titleLabel.setSDText(section.header.title)
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        moreButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        summaryView.bind(section.summary)
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.cards.forEach { card in
            cardsStack.addArrangedSubview(StoreReviewCardView(card: card) { [weak self] action in
                self?.onAction?(action)
            })
        }
        moreButton.setOptionalSDButton(section.more?.button)
        if let action = section.more?.storeSectionAction {
            moreButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}

private final class StoreReviewSummaryView: UIView {
    private let titleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
    private let starsStack = UIStackView()
    private let ratingLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 18))

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = StoreReviewCell.Layout.cardCornerRadius
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        addSubViews([titleLabel, starsStack, ratingLabel])
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.centerX.equalToSuperview()
        }
        starsStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        ratingLabel.snp.makeConstraints {
            $0.centerY.equalTo(starsStack)
            $0.leading.equalTo(starsStack.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(14)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func bind(_ summary: StoreReviewSummary) {
        setSDSurfaceStyle(summary.style)
        titleLabel.setSDText(summary.title)
        ratingLabel.setSDText(summary.rating)
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        summary.stars.images.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setImage(urlString: image.url)
            imageView.snp.makeConstraints { $0.size.equalTo(CGSize(width: image.style.width, height: image.style.height)) }
            starsStack.addArrangedSubview(imageView)
        }
    }
}

private final class StoreReviewCardView: UIView {
    private let headerLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
    private let headerSubTitleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
    private let headerActionButton = UIButton(type: .system)
    private let metadataStack = StoreSectionFlowStackView(spacing: 2)
    private let starsStack = UIStackView()
    private let imageStack = UIStackView()
    private var imageStackHeightConstraint: Constraint?
    private var bodyTopConstraint: Constraint?
    private let bodyLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 14))
    private let replyLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
    private let likeButton = UIButton(type: .system)
    private let action: StoreSectionAction?
    private let headerAction: StoreSectionAction?
    private let likeAction: StoreSectionAction?
    private let onAction: ((StoreSectionAction) -> Void)?

    init(card: StoreReviewCard, onAction: ((StoreSectionAction) -> Void)?) {
        self.action = card.link.map { .link($0, clickLog: card.clickLog) }
        self.headerAction = card.header.trailingAction?.storeSectionAction.map { $0.withCardId(card.cardId) }
        self.likeAction = card.like?.storeSectionAction(isSelected: card.like?.isSelected ?? false).map { $0.withCardId(card.cardId) }
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = StoreReviewCell.Layout.cardCornerRadius
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        imageStack.axis = .horizontal
        imageStack.spacing = 6
        imageStack.distribution = .fillEqually
        addSubViews([
            headerLabel,
            headerSubTitleLabel,
            headerActionButton,
            metadataStack,
            starsStack,
            imageStack,
            bodyLabel,
            replyLabel,
            likeButton
        ])
        let inset = StoreReviewCell.Layout.cardInset
        headerLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(inset)
            $0.trailing.lessThanOrEqualTo(headerSubTitleLabel.snp.leading).offset(-8)
        }
        headerActionButton.snp.makeConstraints { $0.centerY.equalTo(headerLabel); $0.trailing.equalToSuperview().inset(inset) }
        headerSubTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(headerLabel)
            $0.trailing.equalTo(headerActionButton.snp.leading).offset(-6)
        }
        metadataStack.snp.makeConstraints { $0.top.equalTo(headerLabel.snp.bottom).offset(6); $0.leading.trailing.equalToSuperview().inset(inset) }
        starsStack.snp.makeConstraints { $0.top.equalTo(metadataStack.snp.bottom).offset(6); $0.leading.equalToSuperview().inset(inset) }
        imageStack.snp.makeConstraints {
            $0.top.equalTo(starsStack.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(inset)
            imageStackHeightConstraint = $0.height.equalTo(88).constraint
        }
        bodyLabel.snp.makeConstraints {
            bodyTopConstraint = $0.top.equalTo(imageStack.snp.bottom).offset(8).constraint
            $0.leading.trailing.equalToSuperview().inset(inset)
        }
        replyLabel.snp.makeConstraints { $0.top.equalTo(bodyLabel.snp.bottom).offset(8); $0.leading.trailing.equalToSuperview().inset(inset) }
        likeButton.snp.makeConstraints { $0.top.equalTo(replyLabel.snp.bottom).offset(8); $0.leading.equalToSuperview().inset(inset); $0.bottom.equalToSuperview().inset(inset) }
        bind(card)
        if action != nil {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
        }
        if headerAction != nil {
            headerActionButton.addAction(UIAction { [weak self] _ in self?.didTapHeaderAction() }, for: .touchUpInside)
        }
        if likeAction != nil {
            likeButton.addAction(UIAction { [weak self] _ in self?.didTapLike() }, for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func bind(_ card: StoreReviewCard) {
        setSDSurfaceStyle(card.style)
        headerLabel.setSDText(card.header.title)
        headerSubTitleLabel.setSDText(card.header.subTitle)
        headerSubTitleLabel.isHidden = card.header.subTitle == nil
        headerActionButton.setOptionalSDButton(card.header.trailingAction)
        metadataStack.bind(card.metadata)
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        card.stars.images.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setImage(urlString: image.url)
            imageView.snp.makeConstraints { $0.size.equalTo(CGSize(width: image.style.width, height: image.style.height)) }
            starsStack.addArrangedSubview(imageView)
        }
        imageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // 이미지가 없으면 높이와 간격을 접어 빈 공백이 남지 않게 한다.
        imageStack.isHidden = card.images.isEmpty
        imageStackHeightConstraint?.update(offset: card.images.isEmpty ? 0 : 88)
        bodyTopConstraint?.update(offset: card.images.isEmpty ? 0 : 8)
        card.images.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
            imageView.setImage(urlString: image.url)
            imageStack.addArrangedSubview(imageView)
        }
        bodyLabel.setSDText(card.body)
        replyLabel.setSDText(card.reply?.body)
        replyLabel.isHidden = card.reply == nil
        let like = card.like
        likeButton.setOptionalSDButton(like?.isSelected == true ? like?.selected : like?.unselected)
    }

    @objc private func didTapCard() {
        guard let action else { return }
        onAction?(action)
    }

    private func didTapLike() {
        guard let likeAction else { return }
        onAction?(likeAction)
    }

    private func didTapHeaderAction() {
        guard let headerAction else { return }
        onAction?(headerAction)
    }
}

private extension StoreSectionAction {
    func withCardId(_ cardId: String) -> Self {
        guard case let .custom(action, clickLog, _) = self else { return self }
        return .custom(action, clickLog: clickLog, cardId: cardId)
    }
}
