import UIKit

import Common
import DesignSystem
import Model

final class RegisteredStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 114
    }

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray95.color
        return containerView
    }()
    
    private let storeView = UIView()

    private let titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        titleStackView.alignment = .leading
        return titleStackView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 16)
        titleLabel.textColor = Colors.systemWhite.color
        return titleLabel
    }()

    private let tagStackView: UIStackView = {
        let tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 4
        return tagStackView
    }()

    private let tagLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = Fonts.medium.font(size: 12)
        tagLabel.textColor = Colors.gray40.color
        return tagLabel
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let newBadge = UIImageView(image: MyPageAsset.iconNewBadgeShort.image)

    private let bottomView = UIView()

    private let ratingButton: UIButton = {
        let ratingButton = UIButton()
        ratingButton.setImage(
            Icons.starSolid.image
                .resizeImage(scaledTo: 12)
                .withTintColor(Colors.gray40.color), 
            for: .normal
        )
        ratingButton.imageEdgeInsets.right = 2
//        ratingButton.titleEdgeInsets.right = 8
        ratingButton.contentEdgeInsets.right = 8
        ratingButton.setTitleColor(Colors.gray40.color, for: .normal)
        ratingButton.titleLabel?.font = Fonts.bold.font(size: 12)
        return ratingButton
    }()
    
    private let countLabel: PaddingLabel = {
        let countLabel = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 8, rightInset: 8)
        countLabel.font = Fonts.bold.font(size: 12)
        countLabel.textColor = Colors.systemWhite.color
        countLabel.backgroundColor = Colors.gray80.color
        countLabel.layer.cornerRadius = 12
        countLabel.clipsToBounds = true
        return countLabel
    }()
    
    override func setup() {
        super.setup()

        backgroundColor = .clear
        
        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            storeView,
            bottomView,
            newBadge
        ])
        
        storeView.addSubViews([
            titleStackView,
            tagStackView,
            imageView
        ])
        
        titleStackView.addArrangedSubview(tagStackView)
        titleStackView.addArrangedSubview(titleLabel)
    
        tagStackView.addArrangedSubview(tagLabel)
        
        bottomView.addSubview(ratingButton)
        bottomView.addSubview(countLabel)
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        storeView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(48)
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(12)
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(10)
            $0.leading.equalTo(titleStackView)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        ratingButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.equalTo(40)
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        newBadge.snp.makeConstraints {
            $0.size.equalTo(14)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.bottom.equalTo(countLabel.snp.top).offset(-22)
        }
    }

    func bind(item: UserStoreWithVisitsResponse) {
        imageView.setImage(urlString: item.store.categories.first?.imageUrl)
        titleLabel.text = item.store.name
        tagLabel.text = item.store.categories.map { "#\($0.name)" }.joined(separator: " ")
        ratingButton.setTitle("\(item.store.rating)", for: .normal)
        countLabel.text = "최근 방문 \(item.visits.count.existsCounts)명"
        newBadge.isHidden = !item.tags.isNew
    }
}
