import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreCalloutCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let topMargin: CGFloat = 12
        static let cornerRadius: CGFloat = 12
        static let contentInset: CGFloat = 14
        static let verticalInset: CGFloat = 10
        static let iconSize: CGFloat = 21
        static let iconSpacing: CGFloat = 5
        static let minimumHeight: CGFloat = 41
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = Colors.gray90.color
        return view
    }()

    private let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()

    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.iconSpacing
        return stackView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 14))
    private let subTitleLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
    private let footerButton = UIButton(type: .system)

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.clear()
        onAction = nil
    }

    override func setup() {
        titleStack.addArrangedSubview(iconImageView)
        titleStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(titleStack)
        contentStack.addArrangedSubview(subTitleLabel)
        contentStack.addArrangedSubview(footerButton)
        containerView.addSubview(contentStack)
        contentView.addSubview(containerView)
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(Layout.minimumHeight)
        }
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(
                    top: Layout.verticalInset,
                    left: Layout.contentInset,
                    bottom: Layout.verticalInset,
                    right: Layout.contentInset
                )
            )
        }
        iconImageView.snp.makeConstraints { $0.size.equalTo(Layout.iconSize) }
    }

    func bind(_ section: StoreCalloutSection) {
        let content = section.content
        containerView.setSDSurfaceStyle(content.style ?? section.style)

        if let image = content.image {
            iconImageView.setImage(urlString: image.url)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }

        let title = content.text ?? content.title
        titleLabel.setSDText(title)
        titleLabel.isHidden = title == nil

        subTitleLabel.setSDText(content.subTitle)
        subTitleLabel.isHidden = content.subTitle == nil

        footerButton.setOptionalSDButton(content.footerLeftButton)
        footerButton.isHidden = content.footerLeftButton == nil
        footerButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = content.footerLeftButton?.storeSectionAction {
            footerButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}
