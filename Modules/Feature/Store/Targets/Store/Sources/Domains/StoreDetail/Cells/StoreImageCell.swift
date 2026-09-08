import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreImageCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
    }

    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let imageStack = UIStackView()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        imageStack.axis = .horizontal
        imageStack.alignment = .center
        imageStack.spacing = 8
        contentView.addSubViews([titleLabel, actionButton, imageStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }
        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
        imageStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview()
        }
    }

    func bind(_ section: StoreImageSection) {
        titleLabel.setSDText(section.header.title)
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        imageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.cards.forEach { card in
            let cardView = StoreImageCardView(card: card) { [weak self] action in
                self?.onAction?(action)
            }
            // 카드 크기는 서버가 내려준 image.style 을 따른다.
            cardView.snp.makeConstraints {
                $0.width.equalTo(card.image.style.width)
                $0.height.equalTo(card.image.style.height)
            }
            imageStack.addArrangedSubview(cardView)
        }
    }
}

private final class StoreImageCardView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 13))
    private let subtitleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 11))

    private let action: StoreSectionAction?
    private let onAction: ((StoreSectionAction) -> Void)?

    init(card: StoreImageSectionCard, onAction: ((StoreSectionAction) -> Void)?) {
        self.action = card.customAction.map { .custom($0, clickLog: card.clickLog) }
            ?? card.link.map { .link($0, clickLog: card.clickLog) }
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = 10
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubViews([imageView, titleLabel, subtitleLabel])
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.centerY.equalToSuperview().offset(-8) }
        subtitleLabel.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.equalTo(titleLabel.snp.bottom).offset(2) }
        bind(card)
        if action != nil {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func bind(_ card: StoreImageSectionCard) {
        setSDSurfaceStyle(card.style)
        imageView.setImage(urlString: card.image.url)
        titleLabel.setSDText(card.title)
        subtitleLabel.setSDText(card.subTitle)
    }

    @objc private func didTap() {
        guard let action else { return }
        onAction?(action)
    }
}
