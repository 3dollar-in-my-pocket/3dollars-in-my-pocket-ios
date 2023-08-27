import UIKit

import Common
import DesignSystem

final class HomeStoreCardCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 81, height: 152)
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = DesignSystemAsset.Colors.gray100.color
    }
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray40.color
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    private let newBadge = UIImageView(image: HomeAsset.iconNewBadgeShort.image)
    
    private let tagView = HomeCellTagView()
    
    private let infoView = HomeCellInfoView()
    
    let visitButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        $0.layer.cornerRadius = 10
        $0.setImage(DesignSystemAsset.Icons.locationSolid.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.systemWhite.color), for: .normal)
        $0.setTitle(HomeStrings.homeVisitButton, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
        $0.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
    }
    
    func bind(storeCard: StoreCard) {
        categoryImage.setImage(urlString: storeCard.categories.first?.imageUrl)
        categoryLabel.text = storeCard.categoriesString
        titleLabel.text = storeCard.storeName.maxLength(length: 10)
        tagView.bind(existsCount: storeCard.existsCounts)
        newBadge.isHidden = !storeCard.isNew
        infoView.bind(reviewCount: storeCard.reviewsCount, distance: storeCard.distance)
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            categoryImage,
            categoryLabel,
            titleLabel,
            newBadge,
            tagView,
            infoView,
            visitButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        categoryImage.snp.makeConstraints {
            $0.width.height.equalTo(48)
            $0.left.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(categoryImage)
            $0.left.equalTo(categoryImage.snp.right).offset(14)
            $0.right.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
        }
        
        newBadge.snp.makeConstraints {
            $0.width.height.equalTo(14)
            $0.left.equalTo(titleLabel.snp.right).offset(4)
            $0.top.equalTo(titleLabel)
        }
        
        tagView.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        infoView.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.centerY.equalTo(visitButton)
        }
        
        visitButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
