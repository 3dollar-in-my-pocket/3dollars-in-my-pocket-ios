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
    
    private let categoryImage = UIImageView(image: ImageProvider.image(name: "image_empty_category"))
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.text = "주변 2km 이내에\n가게가 없어요."
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.text = "다른 주소로 검색하거나 직접 제보해보세요!"
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
