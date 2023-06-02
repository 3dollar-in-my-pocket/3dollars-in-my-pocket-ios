import UIKit

import DesignSystem

final class WriteDetailCategoryHeaderView: UICollectionReusableView {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.text = ThreeDollarInMyPocketStrings.writeDetailHeaderCategory
    }
    
    private let deleteButton = UIButton().then {
        $0.setTitle(ThreeDollarInMyPocketStrings.writeDetailHeaderDeleteAllMenu, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.mainRed.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        $0.setImage(DesignSystemAsset.Icons.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = DesignSystemAsset.Colors.mainRed.color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = DesignSystemAsset.Colors.gray0.color
        addSubViews([
            titleLabel,
            deleteButton
        ])
    }
    
    private func bindConstraints() {
        if let buttonTitleLabel = deleteButton.titleLabel {
            deleteButton.imageView?.snp.makeConstraints {
                $0.centerY.equalTo(buttonTitleLabel)
                $0.right.equalTo(buttonTitleLabel.snp.left).offset(-4)
                $0.width.height.equalTo(12)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20)
        }
    }
}
