import UIKit

import Common
import DesignSystem

final class BossStoreFeedbackItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 44
    }

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.layer.borderColor = Colors.gray20.color.cgColor
        containerView.layer.borderWidth = 1
        return containerView
    }()

    private let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = Fonts.semiBold.font(size: 12)
        emojiLabel.textColor = Colors.gray95.color
        return emojiLabel
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 12)
        titleLabel.textColor = Colors.gray95.color
        return titleLabel
    }()

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            emojiLabel,
            titleLabel
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emojiLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }

    func bind(emoji: String, title: String, isSelected: Bool) {
        emojiLabel.text = emoji
        titleLabel.text = title
        containerView.layer.borderColor = isSelected ? Colors.mainPink.color.cgColor : Colors.gray20.color.cgColor
        containerView.backgroundColor = isSelected ? Colors.pink100.color : Colors.systemWhite.color
    }
}
