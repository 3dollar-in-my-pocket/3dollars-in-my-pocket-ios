import UIKit

import DesignSystem

final class WriteDetailCollectionItemCell: BaseCollectionViewCell {
    enum Layout {
        static let width = (UIScreen.main.bounds.width - 40 - 24 - 40)/5
        static let size = CGSize(width: width, height: width + 22)
    }
    
    let categoryButton = UIButton().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = Layout.width / 2
        $0.layer.masksToBounds = true
    }
    
    let closeButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.cornerRadius = 8
        $0.setImage(DesignSystemAsset.Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = DesignSystemAsset.Colors.gray0.color
    }
    
    let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray80.color
        $0.text = "추가하기"
        $0.textAlignment = .center
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
            $0.width.height.equalTo(Layout.width)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(categoryButton)
            $0.right.equalTo(categoryButton)
            $0.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
