import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailReviewCell: BaseCollectionViewCell {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    enum Layout {
        static let estimatedHeight: CGFloat = 120
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        return view
    }()
    
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
    
    let likeButton = LikeButton()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        starBadge.prepareForReuse()
        medalBadge.prepareForReuse()
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            nameLabel,
            rightButton,
            dotView,
            dateLabel,
            medalBadge,
            starBadge,
            contentLabel,
            likeButton
        ])
        feedbackGenerator.prepare()
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(likeButton).offset(16)
            $0.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.right.lessThanOrEqualTo(dateLabel.snp.left)
        }
        
        rightButton.snp.makeConstraints {
            $0.right.equalTo(containerView).offset(-16)
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
            $0.left.equalTo(containerView).offset(16)
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.height.equalTo(StoreDetailMedalBadgeView.Layout.height)
        }

        starBadge.snp.makeConstraints {
            $0.centerY.equalTo(medalBadge)
            $0.left.equalTo(medalBadge.snp.right).offset(4)
        }

        contentLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(16)
            $0.right.equalTo(containerView).offset(-16)
            $0.top.equalTo(medalBadge.snp.bottom).offset(8)
        }
        
        likeButton.snp.makeConstraints {
            $0.leading.equalTo(contentLabel)
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
        }
    }
    
    func bind(_ review: StoreDetailReview) {
        nameLabel.text = review.user.name
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
        medalBadge.bind(review.user.medal)
        starBadge.bind(review.rating)
        contentLabel.text = review.contents
        likeButton.bind(count: review.likeCount, reactedByMe: review.reactedByMe)
        
        if review.isOwner {
            containerView.backgroundColor = Colors.pink100.color
            medalBadge.containerView.backgroundColor = Colors.systemWhite.color
            starBadge.containerView.backgroundColor = Colors.systemWhite.color
            rightButton.setTitle(Strings.StoreDetail.Review.edit, for: .normal)
        } else {
            containerView.backgroundColor = Colors.gray0.color
            medalBadge.containerView.backgroundColor = Colors.pink100.color
            starBadge.containerView.backgroundColor = Colors.pink100.color
            rightButton.setTitle(Strings.StoreDetail.Review.report, for: .normal)
        }
        
        likeButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailReviewCell, _) in
                owner.feedbackGenerator.selectionChanged()
            }
            .store(in: &cancellables)
    }
}
