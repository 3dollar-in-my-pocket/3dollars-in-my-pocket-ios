import UIKit

import DesignSystem
import Model

import Kingfisher

final class CategoryFilterButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCategory(_ category: PlatformStoreCategory?) {
        if let category = category {
            setImage(urlString: category.imageUrl) { [weak self] in
                guard let self = self else { return }
                setImage(imageView?.image?.resizeImage(scaledTo: 16), for: .normal)
            }
            setTitle(category.name, for: .normal)
            setTitleColor(DesignSystemAsset.Colors.mainPink.color, for: .normal)
            backgroundColor = DesignSystemAsset.Colors.gray100.color
        } else {
            setImage(DesignSystemAsset.Icons.category.image
                .resizeImage(scaledTo: 16)
                .withTintColor(DesignSystemAsset.Colors.gray70.color), for: .normal)
            setTitle(HomeStrings.homeCategoryFilterButton, for: .normal)
            setTitleColor(DesignSystemAsset.Colors.gray70.color, for: .normal)
            backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        }
    }
    
    private func setup() {
        layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        layer.borderWidth = 1
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        layer.cornerRadius = 10
        setTitle(HomeStrings.homeCategoryFilterButton, for: .normal)
        setTitleColor(DesignSystemAsset.Colors.gray70.color, for: .normal)
        setImage(DesignSystemAsset.Icons.category.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray70.color), for: .normal)
        titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
    }
}
