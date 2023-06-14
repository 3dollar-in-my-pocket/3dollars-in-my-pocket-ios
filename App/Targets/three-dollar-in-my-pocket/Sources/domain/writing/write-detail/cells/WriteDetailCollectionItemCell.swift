import UIKit

import DesignSystem

final class WriteDetailCollectionItemCell: BaseCollectionViewCell {
    enum Layout {
        static let width = (UIScreen.main.bounds.width - 40 - 24 - 40)/5
        static let size = CGSize(width: width, height: width + 22)
    }
    
    let categoryButton = UIButton().then {
        $0.layer.cornerRadius = (Layout.width - 14) / 2
        $0.layer.masksToBounds = true
        $0.layer.borderColor = DesignSystemAsset.Colors.mainPink.color.cgColor
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    let closeButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.cornerRadius = 8
        $0.setImage(DesignSystemAsset.Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = DesignSystemAsset.Colors.gray0.color
        $0.contentEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray80.color
        $0.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        closeButton.isHidden = false
        categoryButton.backgroundColor = .clear
        categoryButton.layer.borderWidth = 0
    }
    
    override func setup() {
        contentView.addSubViews([
            categoryButton,
            closeButton,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        categoryButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(Layout.width - 14)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(categoryButton)
            $0.right.equalTo(categoryButton)
            $0.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(categoryButton.snp.bottom).offset(4)
        }
    }
    
    func bind(category: PlatformStoreCategory?) {
        if let category = category {
            categoryButton.layer.borderWidth = 1
            categoryButton.setImage(urlString: category.imageUrl, state: .normal)
            titleLabel.text = category.name
        } else {
            setAddButton()
        }
    }
    
    private func setAddButton() {
        closeButton.isHidden = true
        categoryButton.backgroundColor = DesignSystemAsset.Colors.gray100.color
        categoryButton.setImage(DesignSystemAsset.Icons.plus.image.withTintColor(DesignSystemAsset.Colors.mainPink.color), for: .normal)
        categoryButton.layer.borderWidth = 0
        titleLabel.text = "추가하기"
    }
}
