import UIKit

import Common
import DesignSystem

final class HomeCellTagView: BaseView {
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray80.color
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private lazy var checkImage = UIImageView(image: DesignSystemAsset.Icons.check.image.withTintColor(DesignSystemAsset.Colors.mainPink.color))
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        $0.text = "최근 방문 5명"
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    override func setup() {
        super.setup()
        
        addSubViews([
            containerView,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(titleLabel.snp.right).offset(8)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(8)
            $0.centerY.equalTo(containerView)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView).priority(.high)
        }
    }
}
