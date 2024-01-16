import UIKit

import Common
import DesignSystem
import SnapKit
import Then
import Model

final class MyPagePollTotalParticipantsCountCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 120 + bottomInset
        static let bottomInset: CGFloat = 8
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
    }
    
    private let imageView = UIImageView().then {
        $0.image = Icons.fireSolid.image.withTintColor(Colors.mainRed.color)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.gray10.color
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray10.color
        $0.textAlignment = .center
        $0.text = "내가 만든 투표에 참여"
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
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(Layout.bottomInset)
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func bind(_ count: Int) {
        titleLabel.text = "총 \(count)명"
    }
}
