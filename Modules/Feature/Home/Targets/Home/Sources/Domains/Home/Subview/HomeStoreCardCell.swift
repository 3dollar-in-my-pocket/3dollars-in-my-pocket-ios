import UIKit

import Common
import DesignSystem
import Model

final class HomeStoreCardCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 81, height: 152)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = DesignSystemAsset.Colors.gray100.color
        return view
    }()
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DesignSystemAsset.Colors.gray40.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = DesignSystemAsset.Colors.systemWhite.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let newBadge = UIImageView(image: HomeAsset.iconNewBadgeShort.image)
    
    private let tagView = HomeCellTagView()
    
    private let bossStoreTagView = BossStoreTagView()
    
    private let infoView = HomeCellInfoView()
    
    let visitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        button.layer.cornerRadius = 10
        button.setImage(DesignSystemAsset.Icons.locationSolid.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.systemWhite.color), for: .normal)
        button.setTitle(HomeStrings.homeVisitButton, for: .normal)
        button.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        return button
    }()
    
    func bind(storeWithExtra: StoreWithExtraResponse) {
        categoryImage.setImage(urlString: storeWithExtra.store.categories.first?.imageUrl)
        categoryLabel.text = storeWithExtra.store.categoriesString
        titleLabel.text = storeWithExtra.store.storeName.maxLength(length: 10)
        setTagView(storeWithExtra: storeWithExtra)
        newBadge.isHidden = storeWithExtra.extra.tags.isNew.isNot
        infoView.bind(reviewCount: storeWithExtra.extra.reviewsCount, distance: storeWithExtra.distanceM)
        visitButton.isHidden = storeWithExtra.store.storeType == .bossStore
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            categoryImage,
            categoryLabel,
            titleLabel,
            newBadge,
            tagView,
            bossStoreTagView,
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
        
        bossStoreTagView.snp.makeConstraints {
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
    
    private func setTagView(storeWithExtra: StoreWithExtraResponse) {
        switch storeWithExtra.store.storeType {
        case .bossStore:
            tagView.isHidden = true
            bossStoreTagView.isHidden = false
        case .userStore:
            tagView.isHidden = false
            bossStoreTagView.isHidden = true
            tagView.bind(existsCount: storeWithExtra.extra.visitCounts?.existsCounts)
        case .unknown:
            return
        }
    }
}
