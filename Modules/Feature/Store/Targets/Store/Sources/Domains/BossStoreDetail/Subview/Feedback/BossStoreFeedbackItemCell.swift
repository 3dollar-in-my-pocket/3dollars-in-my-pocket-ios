import UIKit

import Common
import DesignSystem
import Then

final class BossStoreFeedbackItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 44
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.layer.borderColor = Colors.gray20.color.cgColor
        $0.layer.borderWidth = 1
    }

    private let emojiLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 12)
        $0.textColor = Colors.gray95.color
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.gray95.color
    }

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
