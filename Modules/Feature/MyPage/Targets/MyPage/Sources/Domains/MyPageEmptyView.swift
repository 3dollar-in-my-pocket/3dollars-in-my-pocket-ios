import UIKit

import Common
import DesignSystem

final class MyPageEmptyView: BaseView {
    private let emptyContainerView: UIView = {
        let emptyContainerView = UIView()
        emptyContainerView.backgroundColor = Colors.gray95.color
        emptyContainerView.layer.cornerRadius = 16
        return emptyContainerView
    }()
    
    private let emptyImageView: UIImageView = {
        let emptyImageView = UIImageView()
        emptyImageView.image = Icons.empty100.image
        return emptyImageView
    }()
    
    private let emptyTitleLabel: UILabel = {
        let emptyTitleLabel = UILabel()
        emptyTitleLabel.font = Fonts.semiBold.font(size: 14)
        emptyTitleLabel.textColor = Colors.gray30.color
        emptyTitleLabel.textAlignment = .center
        return emptyTitleLabel
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let emptyDescriptionLabel = UILabel()
        emptyDescriptionLabel.font = Fonts.medium.font(size: 12)
        emptyDescriptionLabel.textColor = Colors.gray60.color
        emptyDescriptionLabel.textAlignment = .center
        return emptyDescriptionLabel
    }()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        addSubViews([
            emptyContainerView,
        ])
        
        emptyContainerView.addSubViews([
            emptyImageView,
            emptyTitleLabel,
            emptyDescriptionLabel
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        emptyContainerView.snp.makeConstraints { 
            $0.edges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(25)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.size.equalTo(100)
        }
        
        emptyTitleLabel.snp.makeConstraints { 
            $0.top.equalTo(emptyImageView.snp.bottom).offset(8)
            $0.leading.trailing.lessThanOrEqualToSuperview().inset(12)
            $0.centerX.equalToSuperview()
        }
        
        emptyDescriptionLabel.snp.makeConstraints { 
            $0.top.equalTo(emptyTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.lessThanOrEqualToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(25)
            $0.centerX.equalToSuperview()
        }
    }
    
    func bind(title: String, description: String? = nil) {
        emptyTitleLabel.text = title
        emptyDescriptionLabel.text = description
    }
}
