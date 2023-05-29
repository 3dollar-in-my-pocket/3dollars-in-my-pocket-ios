import UIKit

import DesignSystem

final class WriteDetailNameCell: BaseCollectionViewCell {
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray10.color
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let nameField = UITextField().then {
        $0.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
        $0.placeholder = ThreeDollarInMyPocketStrings.writeDetailStoreName
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            nameField
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        nameField.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.right.equalTo(containerView).offset(-12)
            $0.centerY.equalTo(containerView)
        }
    }
}
