import UIKit

import Common
import DesignSystem

final class CategoryFilterCell: BaseCollectionViewCell {
    static let size = CGSize(
        width: (UIScreen.main.bounds.width - 48 - 36)/4,
        height: (UIScreen.main.bounds.width - 48 - 36)/4 + 2
    )
    
    private let newBadge = UIImageView(image: HomeAsset.imageNewBadge.image)
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray70.color
        $0.textAlignment = .center
    }
    
    private let selectIndicator = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.pink100.color
        $0.layer.cornerRadius = 28
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemAsset.Colors.mainPink.color.cgColor
        $0.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            selectIndicator.isHidden = !isSelected
        }
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            selectIndicator,
            categoryImage,
            categoryLabel,
            newBadge
        ])
    }
    
    override func bindConstraints() {
        selectIndicator.snp.makeConstraints {
            $0.center.equalTo(categoryImage)
            $0.width.height.equalTo(58)
        }
        
        newBadge.snp.makeConstraints {
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
        newBadge.isHidden = !category.isNew
    }
}
