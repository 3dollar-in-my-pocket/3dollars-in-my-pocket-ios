import UIKit

import Common
import DesignSystem
import Model

final class BossStoreReviewListCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 120
    }
    
    private let storeView = ReviewStoreView()
    
    private let countButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.review.image.resizeImage(scaledTo: 12).withTintColor(Colors.mainPink.color), for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 10)
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
        button.backgroundColor = Colors.gray90.color
        button.layer.cornerRadius = 4
        button.titleEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: -2)
        button.imageEdgeInsets = .init(top: 0, left: -2, bottom: 0, right: 2)
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    
    override func prepareForReuse() {
        super.prepareForReuse()
     
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        contentView.addSubViews([
            storeView,
            countButton,
            dateLabel,
            stackView
        ])
    }
    
    override func bindConstraints() {
        storeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        countButton.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(countButton)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(countButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(_ review: MyStoreFeedback) {
        dateLabel.text = review.date
        storeView.bind(review.store)
        countButton.setTitle("\(review.feedbacks.count)개", for: .normal)
        review.feedbacks.forEach {
            stackView.addArrangedSubview(FeedbackView(feedbackType: $0.feedbackType))
        }
    }
}

private final class FeedbackView: BaseView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray95.color
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }() 
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray0.color
        label.font = Fonts.semiBold.font(size: 14)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray0.color
        label.font = Fonts.semiBold.font(size: 14)
        return label
    }()
    
    init(feedbackType: FeedbackType) {
        super.init(frame: .zero)
        
        bind(feedbackType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setup() {
        addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            emojiLabel,
            descriptionLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        emojiLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    private func bind(_ feedback: FeedbackType) {
        emojiLabel.text = feedback.emoji
        descriptionLabel.text = feedback.description
    }
}
