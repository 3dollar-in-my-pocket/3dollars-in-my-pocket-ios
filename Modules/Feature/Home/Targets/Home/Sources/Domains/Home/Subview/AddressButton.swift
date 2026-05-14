import UIKit

import Common
import DesignSystem

public final class AddressButton: BaseView {
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 9
    }
  
    private let addressButton = UIButton().then {
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        $0.setTitleColor(DesignSystemAsset.Colors.gray100.color, for: .normal)
        $0.contentHorizontalAlignment = .left
    }
    
    private let rightArrowImage = UIImageView().then {
        $0.image = DesignSystemAsset.Icons.arrowRight.image.withTintColor(DesignSystemAsset.Colors.gray30.color)
    }
    
    public override func setup() {
        addSubViews([
            containerView,
            addressButton,
            rightArrowImage
        ])
    }
    
    public override func bindConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(48)
        }
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = DesignSystemAsset.Colors.gray30.color.withAlphaComponent(0).cgColor
        
        addressButton.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(12)
            make.centerY.equalTo(containerView)
            make.right.equalTo(rightArrowImage).offset(-12)
        }
        
        rightArrowImage.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.right.equalTo(containerView).offset(-16)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        
        snp.makeConstraints { make in
            make.edges.equalTo(containerView).priority(.high)
        }
    }
    
    func bind(address: String) {
        addressButton.setTitle(address, for: .normal)
    }

    /// 바텀시트의 .tip → .full 진행도(0~1) 에 맞춰 gray30 테두리 alpha 를 보간한다.
    /// .full 일 때만 1px 테두리가 보이도록 .tip 에서는 alpha 0 으로 둔다.
    public func updateBorder(progress: CGFloat) {
        let clamped = max(0, min(1, progress))
        containerView.layer.borderColor = DesignSystemAsset.Colors.gray30.color
            .withAlphaComponent(clamped)
            .cgColor
    }
}

extension AddressButton {
    public var tap: UIControl.EventPublisher {
        addressButton.controlPublisher(for: .touchUpInside)
    }
    
    public var title: String? {
        set(newValue) {
            addressButton.setTitle(newValue, for: .normal)
        }
        get {
            addressButton.title(for: .normal)
        }
    }
}
