import UIKit

import Base

final class StoreReviewCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(StoreReviewCollectionViewCell.self)"
    static let estimatedHeight: CGFloat = 140
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private let ratingView = RatingView()
    
    let moreButton = UIButton().then {
        $0.setImage(R.image.ic_more_horizontal(), for: .normal)
        $0.isHidden = true
    }
    
    private let titleLabel = TitleLabel(type: .small)
    
    private let nameLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .bold(size: 12)
    }
    
    private let createdAtLabel = UILabel().then {
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 12)
    }
    
    private let replyLabel = UILabel().then {
        $0.textColor = R.color.gray90()
        $0.numberOfLines = 0
        $0.font = .regular(size: 14)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.moreButton.isHidden = true
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.ratingView,
            self.moreButton,
            self.titleLabel,
            self.nameLabel,
            self.createdAtLabel,
            self.replyLabel
        ])
        self.contentView.isUserInteractionEnabled = false
        self.backgroundColor = .clear
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.bottom.equalTo(self.replyLabel).offset(16)
            make.bottom.equalToSuperview()
        }
        
        self.ratingView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(17)
            make.top.equalTo(self.containerView).offset(15)
        }
        
        self.createdAtLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.ratingView)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.ratingView.snp.bottom).offset(14)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel.snp.right).offset(8)
        }
        
        self.replyLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(10)
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-12)
            make.bottom.equalTo(self.containerView).offset(-12)
            make.width.height.equalTo(24)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView).priority(.high)
        }
    }
    
    func bind(review: Review, userId: Int) {
        self.ratingView.bind(rating: review.rating)
        self.titleLabel.bind(title: review.user.medal.name)
        self.nameLabel.text = review.user.name
        self.replyLabel.text = review.contents
        self.createdAtLabel.text = DateUtils.toReviewFormat(
            dateString: review.createdAt
        )
        self.moreButton.isHidden = userId != review.user.userId
    }
}
