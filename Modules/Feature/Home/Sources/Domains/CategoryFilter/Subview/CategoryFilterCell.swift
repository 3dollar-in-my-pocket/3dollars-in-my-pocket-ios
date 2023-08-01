import UIKit

import Common
import DesignSystem

final class CategoryFilterCell: BaseCollectionViewCell {
    static let size = CGSize(
        width: (UIScreen.main.bounds.width - 48 - 36)/4,
        height: (UIScreen.main.bounds.width - 48 - 36)/4 + 2
    )
    
    private let newLabel = UILabel().then {
        $0.text = "new"
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
        $0.textAlignment = .center
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 7
    }
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray70.color
        $0.textAlignment = .center
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            categoryImage,
            categoryLabel,
            newLabel
        ])
    }
    
    override func bindConstraints() {
        newLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(14)
        }
        
        categoryImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(56)
            $0.height.equalTo(56)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(categoryImage.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(category: PlatformStoreCategory) {
        categoryLabel.text = category.name
        categoryImage.setImage(urlString: category.imageUrl)
        newLabel.isHidden = category.isNew
    }
}
