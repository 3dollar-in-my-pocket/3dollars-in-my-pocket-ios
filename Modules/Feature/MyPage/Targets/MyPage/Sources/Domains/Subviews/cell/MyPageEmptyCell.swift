import UIKit

import Common
import DesignSystem
import SnapKit
import Then
import Model

final class MyPageEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 118
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray60.color
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray70.color
        $0.textAlignment = .center
    }
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            imageView,
            titleLabel,
            descriptionLabel
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func bind(_ type: MyPageSectionType) {
        imageView.image = type.emptyIcon?.withTintColor(Colors.gray80.color)
        titleLabel.text = type.emptyTitle
        descriptionLabel.text = type.emptyDescription
    }
}
