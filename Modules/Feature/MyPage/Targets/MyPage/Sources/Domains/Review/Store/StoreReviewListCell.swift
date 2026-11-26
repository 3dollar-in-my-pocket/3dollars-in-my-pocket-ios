import UIKit

import Common
import DesignSystem
import Model

final class StoreReviewListCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 120
    }
    
    private let storeView = ReviewStoreView()
    
    private let ratingView: Rating = {
        let rating = Rating(style: .none)
        rating.customBackgroundColor = Colors.gray90.color
        return rating
    }()
    
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
    
    override func setup() {
        contentView.addSubViews([
            storeView,
            dateLabel,
            ratingView,
            contentLabel
        ])
    }
    
    override func bindConstraints() {
        storeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        ratingView.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.size.equalTo(Rating.Layout.size)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(ratingView)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(ratingView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bind(_ review: MyStoreReview) {
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
        ratingView.bind(review.rating)
        contentLabel.text = review.contents
        contentLabel.setLineHeight(lineHeight: 20)
        storeView.bind(review.store)
    }
}
