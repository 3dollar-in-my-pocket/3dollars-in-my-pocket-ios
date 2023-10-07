import UIKit

import Common
import DesignSystem
import Model

final class ReviewListCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 120
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.StoreDetail.Review.report, for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        
        return button
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray40.color
        view.layer.cornerRadius = 1
        
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let medalBadge = StoreDetailMedalBadgeView()
    
    private let starBadge = StoreDetailStarBadgeView()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.regular.font(size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        starBadge.prepareForReuse()
    }
    
    override func setup() {
        contentView.addSubViews([
            nameLabel,
            rightButton,
            dotView,
            dateLabel,
            medalBadge,
            starBadge,
            contentLabel
        ])
    }
    
    override func bindConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(20)
            $0.right.lessThanOrEqualTo(dateLabel.snp.left)
        }
        
        rightButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(nameLabel)
        }
        
        dotView.snp.makeConstraints {
            $0.centerY.equalTo(rightButton)
            $0.size.equalTo(2)
            $0.right.equalTo(rightButton.snp.left).offset(-4)
        }
        
        dateLabel.snp.makeConstraints {
            $0.right.equalTo(dotView.snp.left).offset(-4)
            $0.centerY.equalTo(dotView)
        }
        
        medalBadge.snp.makeConstraints {
            $0.left.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        starBadge.snp.makeConstraints {
            $0.centerY.equalTo(medalBadge)
            $0.left.equalTo(medalBadge.snp.right).offset(4)
        }

        contentLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(medalBadge.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func bind(_ review: StoreDetailReview) {
        nameLabel.text = review.user.name
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
        medalBadge.bind(review.user.medal)
        starBadge.bind(review.rating)
        contentLabel.text = review.contents
        
        if UserDefaultsUtil().userId == review.user.userId {
            contentView.backgroundColor = Colors.pink100.color
            medalBadge.containerView.backgroundColor = Colors.systemWhite.color
            starBadge.containerView.backgroundColor = Colors.systemWhite.color
            rightButton.setTitle(Strings.StoreDetail.Review.edit, for: .normal)
        } else {
            contentView.backgroundColor = Colors.gray0.color
            medalBadge.containerView.backgroundColor = Colors.pink100.color
            starBadge.containerView.backgroundColor = Colors.pink100.color
            rightButton.setTitle(Strings.StoreDetail.Review.report, for: .normal)
        }
    }
}
