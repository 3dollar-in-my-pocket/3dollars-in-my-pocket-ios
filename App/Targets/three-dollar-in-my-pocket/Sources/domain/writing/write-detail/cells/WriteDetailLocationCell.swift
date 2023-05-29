import UIKit

import DesignSystem

final class WriteDetailAddressLocationCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray10.color
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let addressLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
    }
    
    let editAddressButton = UIButton().then {
        $0.setTitleColor(DesignSystemAsset.Colors.mainPink.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        $0.setTitle(ThreeDollarInMyPocketStrings.writeDetailEditLocation, for: .normal)
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            addressLabel,
            editAddressButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        addressLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.right.equalTo(editAddressButton.snp.left).offset(-10)
            $0.centerY.equalTo(containerView)
        }
        
        editAddressButton.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.right.equalTo(containerView).offset(-12)
        }
    }
    
    func bind(address: String) {
        addressLabel.text = address
    }
}
