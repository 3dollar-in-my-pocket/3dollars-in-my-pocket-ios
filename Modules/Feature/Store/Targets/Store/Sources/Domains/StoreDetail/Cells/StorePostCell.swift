import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StorePostCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let cardStack = UIStackView()

    override func prepareForReuse() {
        super.prepareForReuse()
        cardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        cardStack.axis = .vertical
        cardStack.spacing = 12
        contentView.addSubViews([titleLabel, actionButton, cardStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        actionButton.snp.makeConstraints { $0.top.trailing.equalToSuperview() }
        cardStack.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(12); $0.leading.trailing.bottom.equalToSuperview() }
    }

    func bind(_ section: StorePostSection) {
        titleLabel.setSDText(section.header.title)
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        cardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.cards.forEach { card in
            cardStack.addArrangedSubview(StorePostCardView(card: card) { [weak self] action in
                self?.onAction?(action)
            })
        }
    }
}

private final class StorePostCardView: UIView {
    private let headerLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
    private let imageView = UIImageView()
    private let bodyLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 14))
    private let likeButton = UIButton(type: .system)
    private let action: StoreSectionAction?
    private let likeAction: StoreSectionAction?
    private let onAction: ((StoreSectionAction) -> Void)?

    init(card: StorePostContentCard, onAction: ((StoreSectionAction) -> Void)?) {
        self.action = card.link.map { .link($0, clickLog: card.clickLog) }
        self.likeAction = card.like?.storeSectionAction(isSelected: card.like?.isSelected ?? false)
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = 12
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubViews([headerLabel, imageView, bodyLabel, likeButton])
        headerLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview().inset(14) }
        imageView.snp.makeConstraints { $0.top.equalTo(headerLabel.snp.bottom).offset(8); $0.leading.trailing.equalToSuperview(); $0.height.equalTo(160) }
        bodyLabel.snp.makeConstraints { $0.top.equalTo(imageView.snp.bottom).offset(10); $0.leading.trailing.equalToSuperview().inset(14) }
        likeButton.snp.makeConstraints { $0.top.equalTo(bodyLabel.snp.bottom).offset(8); $0.leading.equalToSuperview().inset(14); $0.bottom.equalToSuperview().inset(14) }
        bind(card)
        if action != nil {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
        }
        if likeAction != nil {
            likeButton.addAction(UIAction { [weak self] _ in self?.didTapLike() }, for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func bind(_ card: StorePostContentCard) {
        setSDSurfaceStyle(card.style)
        headerLabel.setSDChip(card.header)
        bodyLabel.setSDText(card.body)
        imageView.isHidden = card.images.isEmpty
        if let image = card.images.first { imageView.setImage(urlString: image.url) }
        let like = card.like
        likeButton.setOptionalSDButton(like?.isSelected == true ? like?.selected : like?.unselected)
    }

    @objc private func didTapCard() {
        guard let action else { return }
        onAction?(action)
    }

    @objc private func didTapLike() {
        guard let likeAction else { return }
        onAction?(likeAction)
    }
}
