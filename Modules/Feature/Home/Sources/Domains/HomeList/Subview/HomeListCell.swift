import UIKit

import Common
import DesignSystem

public class HomeListCell: BaseCollectionViewCell {
    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 128)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 20
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
    
    private let tagView = HomeCellTagView()
    
    private let infoView = HomeCellInfoView()
    
    public override func setup() {
        addSubViews([
            containerView,
            categoryImage,
            categoryLabel,
            titleLabel,
            tagView,
            infoView
        ])
    }
    
    public override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        categoryImage.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(12)
            $0.width.height.equalTo(38)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel)
            $0.left.equalTo(categoryLabel.snp.right).offset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
        }
        
        tagView.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        infoView.snp.makeConstraints {
            $0.left.equalTo(tagView)
            $0.bottom.equalTo(containerView).offset(-14)
        }
    }
    
    func bind(storeCard: StoreCard) {
        categoryImage.setImage(urlString: storeCard.categories.first?.imageUrl)
        categoryLabel.text = storeCard.categoriesString
        titleLabel.text = storeCard.storeName
        tagView.bind(existsCount: storeCard.existsCounts)
        infoView.bind(reviewCount: storeCard.reviewsCount, distance: storeCard.distance)
    }
}
