import UIKit

import Common
import DesignSystem
import Then
import Model

final class CommunityPopularStoreNeighborhoodsCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 44
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.layer.borderColor = Colors.gray40.color.cgColor
        $0.layer.borderWidth = 1
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray60.color
    }

    private let checkImageView = UIImageView().then {
        $0.image = Icons.check.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainRed.color)
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleLabel,
            checkImageView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }

    func bind(item: CommunityNeighborhoods) {
        titleLabel.text = item.description
        titleLabel.textColor = item.isSelected ? Colors.gray100.color : Colors.gray60.color
        containerView.layer.borderColor = item.isSelected ? Colors.mainRed.color.cgColor : Colors.gray40.color.cgColor
        checkImageView.isHidden = !item.isSelected
    }
}
