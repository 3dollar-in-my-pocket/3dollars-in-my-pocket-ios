import UIKit

import Common
import DesignSystem

final class HomeListHeaderCell: BaseCollectionViewReusableView {
    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Layout.height)
        static let height: CGFloat = 76
    }
    
    let titleLabel = UILabel().then {
        $0.textColor = DesignSystemAsset.Colors.systemBlack.color
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        $0.textAlignment = .left
    }
    
    let isOnlyCertifiedButton = UIButton().then {
        $0.setTitle(HomeStrings.homeListIsOnlyCertified, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.gray60.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.checkBoxOff.image, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.checkBoxOn.image, for: .selected)
        $0.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        $0.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            isOnlyCertifiedButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
        }
        
        isOnlyCertifiedButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20)
        }
    }
    
    func bind(category: PlatformStoreCategory?) {
        if let category {
            titleLabel.text = category.description
        } else {
            titleLabel.text = HomeStrings.homeListHeaderTotal
        }
    }
}
