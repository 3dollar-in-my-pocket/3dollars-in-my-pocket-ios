import UIKit

import Common
import DesignSystem

final class HomeStoreEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 81, height: 152)
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = DesignSystemAsset.Colors.gray100.color
    }
    
    private let categoryImage = UIImageView(image: HomeAsset.imageEmptyCategory.image)
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.text = HomeStrings.homeEmptyTitle
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.text = HomeStrings.homeEmptyDescription
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            categoryImage,
            titleLabel,
            descriptionLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        categoryImage.snp.makeConstraints {
            $0.width.height.equalTo(48)
            $0.left.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(categoryImage.snp.right).offset(14)
            $0.top.equalTo(categoryImage)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
}
