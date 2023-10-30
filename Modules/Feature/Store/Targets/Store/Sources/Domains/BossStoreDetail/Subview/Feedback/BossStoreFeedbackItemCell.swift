import UIKit

import Common
import DesignSystem
import Then

final class BossStoreFeedbackItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 52
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.layer.borderColor = Colors.gray20.color.cgColor
        $0.layer.borderWidth = 1
    }

    private let emojiLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray95.color
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray95.color
    }

    private let checkImageView = UIImageView().then {
        $0.image = Icons.check.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainPink.color)
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            emojiLabel,
            titleLabel,
            checkImageView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
        }

        emojiLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    func bind(emoji: String, title: String, isSelected: Bool) {
        emojiLabel.text = emoji
        titleLabel.text = title
        containerView.layer.borderColor = isSelected ? Colors.mainPink.color.cgColor : Colors.gray20.color.cgColor
        containerView.backgroundColor = isSelected ? Colors.pink100.color : Colors.systemWhite.color
        checkImageView.isHidden = !isSelected
    }
}
