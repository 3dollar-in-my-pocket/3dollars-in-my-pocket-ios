import UIKit

final class MyReviewCell: BaseTableViewCell {
    static let registerId = "\(MyReviewCell.self)"
    
    private let categoryImage = UIImageView()
    
    private let storeNameLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = .white
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 12
    }
    
    private let ratingView = RatingView()
    
    private let dateLabel = UILabel().then {
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 12)
    }
    
    private let titleLabel = ReviewTitleLabel()
    
    private let userNameLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .bold(size: 12)
    }
    
    private let reviewLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.font = .regular(size: 14)
    }
    
    let moreButton = UIButton().then {
        $0.setImage(R.image.ic_more_horizontal(), for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = false
        self.addSubViews([
            self.categoryImage,
            self.storeNameLabel,
            self.containerView,
            self.ratingView,
            self.dateLabel,
            self.titleLabel,
            self.userNameLabel,
            self.reviewLabel,
            self.moreButton
        ])
    }
    
    override func bindConstraints() {
        self.categoryImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(24)
            make.top.equalToSuperview().offset(21)
        }
        
        self.storeNameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.categoryImage.snp.right).offset(8)
            make.centerY.equalTo(self.categoryImage)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.categoryImage.snp.bottom).offset(11)
            make.bottom.equalTo(self.reviewLabel).offset(25)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        self.ratingView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(17)
            make.top.equalTo(self.containerView).offset(15)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.ratingView)
            make.right.equalTo(self.containerView).offset(-8)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.ratingView)
            make.top.equalTo(self.ratingView.snp.bottom).offset(17)
        }
        
        self.userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(8)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.reviewLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-6)
            make.bottom.equalTo(self.containerView).offset(-6)
            make.width.height.equalTo(24)
        }
    }
    
    func bind(review: Review) {
        self.categoryImage.image = review.category.image
        self.storeNameLabel.text = review.store.storeName
        self.ratingView.bind(rating: review.rating)
        self.dateLabel.text = DateUtils.toReviewFormat(dateString: review.createdAt)
        self.titleLabel.bind(title: review.user.medal.name)
        self.userNameLabel.text = review.user.name
        self.reviewLabel.text = review.contents
    }
}
