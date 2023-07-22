import UIKit

import Common
import DesignSystem

final class CategoryFilterCell: BaseCollectionViewCell {
    static let size = CGSize(
        width: (UIScreen.main.bounds.width - 48 - 39)/4,
        height: (UIScreen.main.bounds.width - 48 - 39)/4 + 25
    )
    
    private let newLabel = UILabel().then {
        $0.text = "new"
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
        $0.textAlignment = .center
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 9
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 17
    }
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel = UILabel().then {
        // TODO: extraBold 폰트 필요?
//        $0.font = .extraBold(size: 14)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            containerView,
            newLabel,
            categoryImage,
            categoryLabel
        ])
    }
    
    override func bindConstraints() {
        newLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(18)
            $0.width.equalTo(32)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(newLabel).offset(9)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(Self.size.width)
        }
        
        categoryImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(containerView).offset(10)
            $0.width.equalTo(60)
            $0.height.equalTo(60)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(10)
            $0.right.equalTo(containerView).offset(-10)
            $0.top.equalTo(categoryImage.snp.bottom).offset(4)
        }
    }
    
    func bind(category: PlatformStoreCategory) {
        categoryLabel.text = category.name
        categoryImage.setImage(urlString: category.imageUrl)
        newLabel.isHidden = category.isNew
    }
}
