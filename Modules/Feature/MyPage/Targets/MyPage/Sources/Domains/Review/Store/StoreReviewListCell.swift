import UIKit

import Common
import DesignSystem
import Model

final class StoreReviewListCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 120
    }
    
    private let storeView = StoreView()
    
    private let starBadge = StarBadgeView()
    
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
            $0.size.equalTo(StarBadgeView.Layout.size)
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

// MARK: - StarBadgeView
// TODO: 공용으로 옮기기
private final class StarBadgeView: BaseView {
    enum Layout {
        static let size = CGSize(width: 68, height: 20)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        
        return stackView
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            stackView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalTo(stackView).offset(4)
            $0.bottom.equalTo(stackView).offset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(4)
            $0.top.equalTo(containerView).offset(4)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
    }
    
    func prepareForReuse() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func bind(_ rating: Int) {
        for index in 0..<5 {
            if rating >= index + 1 {
                let starImageView = UIImageView(image: Icons.starSolid.image.withTintColor(Colors.mainPink.color))
                starImageView.snp.makeConstraints {
                    $0.size.equalTo(12)
                }
                
                stackView.addArrangedSubview(starImageView)
            } else {
                let starImageView = UIImageView(image: Icons.starSolid.image.withTintColor(Colors.gray70.color))
                starImageView.snp.makeConstraints {
                    $0.size.equalTo(12)
                }
                
                stackView.addArrangedSubview(starImageView)
            }
        }
    }
}

// MARK: - StoreView

private final class StoreView: BaseView {

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.mainPink.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray80.color
        return view
    }()
    
    override func setup() {
        addSubViews([
            imageView,
            nameLabel,
            dividerView
        ])
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.centerY.equalTo(imageView)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(nameLabel)
        }
    }
    
    func bind(_ store: PlatformStore) {
        imageView.setImage(urlString: store.categories.first?.imageUrl)
        nameLabel.text = store.name
    }
}
