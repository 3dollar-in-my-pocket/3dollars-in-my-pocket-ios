import UIKit

import Common
import DesignSystem
import Then
import Model

final class RegisteredStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 114
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
    }
    
    private let storeView = UIView()

    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.systemWhite.color
    }

    private let tagStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let tagLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray40.color
    }

    private let imageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private let newBadge = UIImageView(image: MyPageAsset.iconNewBadgeShort.image)

    private let bottomView = UIView()

    private let ratingButton = UIButton().then {
        $0.setImage(
            Icons.starSolid.image
                .resizeImage(scaledTo: 12)
                .withTintColor(Colors.gray40.color), 
            for: .normal
        )
        $0.imageEdgeInsets.right = 2
//        $0.titleEdgeInsets.right = 8
        $0.contentEdgeInsets.right = 8
        $0.setTitleColor(Colors.gray40.color, for: .normal)
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
    }
    
    private let countLabel = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 8, rightInset: 8).then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.systemWhite.color
        $0.backgroundColor = Colors.gray80.color
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
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
