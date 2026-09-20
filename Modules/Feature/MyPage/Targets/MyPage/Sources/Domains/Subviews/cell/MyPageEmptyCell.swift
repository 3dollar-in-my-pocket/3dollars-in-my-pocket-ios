import UIKit

import Common
import DesignSystem
import SnapKit
import Model

final class MyPageEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 118
    }
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray95.color
        return containerView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 16)
        titleLabel.textColor = Colors.gray60.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.medium.font(size: 12)
        descriptionLabel.textColor = Colors.gray70.color
        descriptionLabel.textAlignment = .center
        return descriptionLabel
    }()
    
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
