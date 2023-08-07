import UIKit

import Common
import DesignSystem

final class HomeListHeaderCell: BaseCollectionViewReusableView {
    static let registerId = "\(HomeListHeaderCell.self)"
    static let height: CGFloat = 76
    
    private let titleLabel = UILabel().then {
        $0.textColor = DesignSystemAsset.Colors.systemBlack.color
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        $0.textAlignment = .left
        $0.text = "전체 메뉴"
    }
    
    let visitFilterButton = UIButton().then {
        $0.setTitle("방문 인증 가게", for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.gray60.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.checkBoxOff.image, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            visitFilterButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
        }
        
        visitFilterButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20)
        }
    }
}
