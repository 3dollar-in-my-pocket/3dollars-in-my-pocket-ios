import UIKit

import Common
import DesignSystem
import SnapKit
import Model

final class MyPagePollTotalParticipantsCountCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 120 + bottomInset
        static let bottomInset: CGFloat = 8
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
        imageView.image = Icons.fireSolid.image.withTintColor(Colors.mainRed.color)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 24)
        titleLabel.textColor = Colors.gray10.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.medium.font(size: 12)
        descriptionLabel.textColor = Colors.gray10.color
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "내가 만든 투표에 참여"
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
