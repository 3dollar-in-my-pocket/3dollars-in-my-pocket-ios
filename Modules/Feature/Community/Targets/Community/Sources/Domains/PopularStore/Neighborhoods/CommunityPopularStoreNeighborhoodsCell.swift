import UIKit

import Common
import DesignSystem
import Model

final class CommunityPopularStoreNeighborhoodsCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 44
    }

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.layer.borderColor = Colors.gray40.color.cgColor
        containerView.layer.borderWidth = 1
        return containerView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.regular.font(size: 14)
        titleLabel.textColor = Colors.gray60.color
        return titleLabel
    }()
    
    private let rightArrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.icRightArrow.image
        return imageView
    }()

    private let checkImageView: UIImageView = {
        let checkImageView = UIImageView()
        checkImageView.image = Icons.check.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainRed.color)
        return checkImageView
    }()

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleLabel,
            rightArrowImage,
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
        
        rightArrowImage.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
        }

        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
    
    func bind(item: NeighborhoodProtocol) {
        titleLabel.text = item.description
        titleLabel.textColor = item.isSelected ? Colors.gray100.color : Colors.gray60.color
        containerView.layer.borderColor = item.isSelected ? Colors.mainRed.color.cgColor : Colors.gray40.color.cgColor
        checkImageView.isHidden = !item.isSelected
        rightArrowImage.isHidden = !item.hasChild
    }
}
