import UIKit

import DesignSystem

final class CategorySelectionCell: BaseCollectionViewCell {
    enum Layout {
        static let imageWidth: CGFloat = (UIScreen.main.bounds.width - 40 - 64)/5
        static let size = CGSize(width: imageWidth, height: imageWidth + 22)
    }
    
    override var isSelected: Bool {
        didSet {
            categoryButton.layer.borderColor = isSelected ? DesignSystemAsset.Colors.mainPink.color.cgColor : DesignSystemAsset.Colors.gray30.color.cgColor
        }
    }
    
    let categoryButton = UIButton().then {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = Layout.imageWidth / 2
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray90.color
        $0.textAlignment = .center
    }
    
    override func setup() {
        contentView.addSubViews([
            categoryButton,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        categoryButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(Layout.imageWidth)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(category: PlatformStoreCategory) {
        titleLabel.text = category.name
        categoryButton.setImage(urlString: category.disableImageUrl, state: .normal)
        categoryButton.setImage(urlString: category.imageUrl, state: .selected)
    }
}
