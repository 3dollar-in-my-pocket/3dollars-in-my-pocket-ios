import UIKit

import Common
import DesignSystem
import Then

final class MyPageEmptyView: BaseView {
    private let emptyContainerView = UIView().then {
        $0.backgroundColor = Colors.gray95.color
        $0.layer.cornerRadius = 16
    }
    
    private let emptyImageView = UIImageView().then {
        $0.image = Icons.empty100.image
    }
    
    private let emptyTitleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray30.color
        $0.textAlignment = .center
    }
    
    private let emptyDescriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.textAlignment = .center
    }
    
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
    
    func bind(title: String, description: String) {
        emptyTitleLabel.text = title
        emptyDescriptionLabel.text = description
    }
}
