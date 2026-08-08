import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreScreenPreviewCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return stack
    }()
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 20))
    private let badgeImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let primaryMetadataStack = StoreSectionFlowStackView(spacing: 4)
    private let secondaryMetadataStack = StoreSectionFlowStackView(spacing: 4)
    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    private let imageStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    private let bodiesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        actionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        imageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bodiesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(badgeImageView)
        [titleStack, primaryMetadataStack, secondaryMetadataStack, actionStack, imageStack, bodiesStack]
            .forEach { contentStack.addArrangedSubview($0) }
        containerView.addSubview(contentStack)
        contentView.addSubview(containerView)
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        badgeImageView.snp.makeConstraints { $0.size.lessThanOrEqualTo(24) }
        actionStack.snp.makeConstraints { $0.height.equalTo(36) }
        imageStack.snp.makeConstraints { $0.height.equalTo(120) }
    }

    func bind(_ section: StoreScreenPreviewSection) {
        containerView.setSDSurfaceStyle(section.style)
        titleLabel.setSDText(section.header.title)
        badgeImageView.isHidden = section.header.badge == nil
        if let badge = section.header.badge {
            badgeImageView.setImage(urlString: badge.url)
            badgeImageView.snp.updateConstraints {
                $0.width.equalTo(badge.style.width)
                $0.height.equalTo(badge.style.height)
            }
        }

        primaryMetadataStack.bind(section.metadata.primary)
        secondaryMetadataStack.bind(section.metadata.secondary)
        primaryMetadataStack.isHidden = section.metadata.primary.isEmpty
        secondaryMetadataStack.isHidden = section.metadata.secondary.isEmpty

        actionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        (section.actionBars + [section.contributorActionBar].compactMap { $0 }).forEach { actionBar in
            let button = UIButton(type: .system)
            button.titleLabel?.font = Fonts.semiBold.font(size: 14)
            button.setSDButton(actionBar.button)
            if let action = actionBar.storeSectionAction {
                button.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
            }
            actionStack.addArrangedSubview(button)
        }
        actionStack.isHidden = section.actionBars.isEmpty

        imageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.images.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.setImage(urlString: image.url)
            imageStack.addArrangedSubview(imageView)
        }
        imageStack.isHidden = section.images.isEmpty

        bodiesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.bodies.forEach { body in
            let bodyView = StoreScreenPreviewBodyView(body: body)
            bodiesStack.addArrangedSubview(bodyView)
        }
        bodiesStack.isHidden = section.bodies.isEmpty
    }
}

private final class StoreScreenPreviewBodyView: UIView {
    private let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))

    init(body: StorePreviewBody) {
        super.init(frame: .zero)
        layer.cornerRadius = 10
        addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
        label.setSDText(body.text)
        setSDSurfaceStyle(body.style)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
