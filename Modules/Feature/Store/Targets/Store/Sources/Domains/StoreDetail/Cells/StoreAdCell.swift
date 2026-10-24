import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreAdCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let verticalMargin: CGFloat = 16
        static let cardInset: CGFloat = 12
        static let imageSize: CGFloat = 64
        static let trailingIconSize: CGFloat = 24
        static let titleHeight: CGFloat = 24
        static let subTitleHeight: CGFloat = 18
    }

    var onTap: ((SDAdCard) -> Void)?

    private var card: SDAdCard?

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.gray10.color.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.gray20.color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Colors.gray10.color.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

    private let labelChipStackView = SDLabelChipStackView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let trailingIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func setup() {
        contentView.addSubview(cardView)
        cardView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(textStackView)
        contentStackView.addArrangedSubview(trailingIconView)
        textStackView.addArrangedSubview(labelChipStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subTitleLabel)

        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
    }

    override func bindConstraints() {
        cardView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(Layout.verticalMargin)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalMargin)
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.cardInset)
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(Layout.imageSize)
        }

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.titleHeight)
            $0.width.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.subTitleHeight)
            $0.width.equalToSuperview()
        }

        trailingIconView.snp.makeConstraints {
            $0.size.equalTo(Layout.trailingIconSize)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
        trailingIconView.clear()
        onTap = nil
        card = nil
    }

    func bind(_ section: StoreAdSection) {
        let card = section.cards.first
        self.card = card
        cardView.isHidden = card == nil
        guard let card else { return }

        imageView.isHidden = card.image == nil
        imageView.setImage(urlString: card.image?.url)

        labelChipStackView.bind(card.labels)
        titleLabel.setSDText(card.title, customFont: Fonts.bold.font(size: 16))
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.isHidden = card.title == nil
        subTitleLabel.setSDText(card.subTitle, customFont: Fonts.medium.font(size: 12))
        subTitleLabel.lineBreakMode = .byTruncatingTail
        subTitleLabel.isHidden = card.subTitle == nil

        trailingIconView.isHidden = card.trailingIcon == nil
        trailingIconView.setImage(urlString: card.trailingIcon?.url)
        accessibilityLabel = titleLabel.text
    }

    @objc private func didTapCard() {
        guard let card else { return }
        onTap?(card)
    }
}
