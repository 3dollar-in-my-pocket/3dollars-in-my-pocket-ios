import UIKit

import Common
import DesignSystem
import Model

final class StoreReviewListCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 120
    }
    
    private let storeView = ReviewStoreView()
    
    private let starBadge = ReviewStarBadgeView()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray0.color
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
            storeView,
            dateLabel,
            starBadge,
            contentLabel
        ])
    }
    
    override func bindConstraints() {
        storeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        starBadge.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.size.equalTo(ReviewStarBadgeView.Layout.size)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(starBadge)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(starBadge.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bind(_ review: MyStoreReview) {
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
        starBadge.bind(review.rating)
        contentLabel.text = review.contents
        contentLabel.setLineHeight(lineHeight: 20)
        starBadge.containerView.backgroundColor = Colors.gray90.color
        storeView.bind(review.store)
    }
}
