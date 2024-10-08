import UIKit

import Common
import DesignSystem
import Model

public class HomeListCell: BaseCollectionViewCell {
    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 128)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        view.layer.cornerRadius = 20
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
        label.textColor = DesignSystemAsset.Colors.gray100.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let newBadge = UIImageView(image: HomeAsset.iconNewBadgeShort.image)
    
    private let tagView = HomeListCellTagView()
    
    private let infoView = HomeListCellInfoView()
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        tagView.prepareForReuse()
        infoView.prepareForReuse()
    }
    
    public override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            containerView,
            categoryImage,
            categoryLabel,
            titleLabel,
            newBadge,
            tagView,
            infoView
        ])
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        categoryImage.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(12)
            $0.width.height.equalTo(48)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(categoryImage)
            $0.left.equalTo(categoryImage.snp.right).offset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
            $0.height.equalTo(24)
        }
        
        newBadge.snp.makeConstraints {
            $0.width.height.equalTo(14)
            $0.left.equalTo(titleLabel.snp.right).offset(4)
            $0.top.equalTo(titleLabel).offset(2)
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
    
    func bind(_ storeWithExtra: StoreWithExtraResponse) {
        categoryImage.setImage(urlString: storeWithExtra.store.categories.first?.imageUrl)
        categoryLabel.text = storeWithExtra.store.categoriesString
        titleLabel.text = storeWithExtra.store.storeName.maxLength(length: 10)
        newBadge.isHidden = storeWithExtra.extra.tags.isNew.isNot
        infoView.bind(storeWithExtra)
        
        if storeWithExtra.store.storeType == .bossStore {
            tagView.bind(type: .boss)
        } else {
            let visitCount = storeWithExtra.extra.visitCounts?.existsCounts ?? 0
            tagView.bind(type: .recentVisit(count: visitCount))
        }
    }
}
