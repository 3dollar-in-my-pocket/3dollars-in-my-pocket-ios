import UIKit
import Combine

import Common
import DesignSystem

final class SettingMenuCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 56)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.gray95.color
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.regular.font(size: 14)
        label.textAlignment = .left
        
        return label
    }()
    
    private let rightArrowImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = Icons.arrowRight.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.systemWhite.color
        return imageView
    }()
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            titleLabel,
            rightArrowImage
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.leading.equalTo(containerView).offset(16)
            $0.trailing.lessThanOrEqualTo(rightArrowImage.snp.leading).offset(-12)
        }
        
        rightArrowImage.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.centerY.equalTo(containerView)
            $0.size.equalTo(12)
        }
    }
    
    func bind(cellType: SettingCellType) {
        titleLabel.text = cellType.title
    }
}
