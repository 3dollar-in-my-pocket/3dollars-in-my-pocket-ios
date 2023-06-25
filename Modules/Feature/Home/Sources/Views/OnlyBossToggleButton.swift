import UIKit

import DesignSystem

public final class OnlyBossToggleButton: UIButton {
    public override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        layer.borderWidth = 1
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        layer.cornerRadius = 10
        setTitle("사장님 직영점만", for: .normal)
        setTitleColor(DesignSystemAsset.Colors.gray40.color, for: .normal)
        setTitleColor(DesignSystemAsset.Colors.gray70.color, for: .selected)
        setImage(DesignSystemAsset.Icons.check.image
            .resizeImage(scaledTo: 16)
            .withRenderingMode(.alwaysTemplate), for: .normal)
        imageView?.tintColor = DesignSystemAsset.Colors.gray40.color
        titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
    }
    
    private func setSelected(_ isSelected: Bool) {
        imageView?.tintColor = isSelected ? DesignSystemAsset.Colors.gray70.color : DesignSystemAsset.Colors.gray40.color
    }
}
