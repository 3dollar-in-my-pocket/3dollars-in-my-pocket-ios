import UIKit

import Common
import DesignSystem
import Model

final class CategoryFilterCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(
            width: (UIScreen.main.bounds.width - 48 - 36)/4,
            height: (UIScreen.main.bounds.width - 48 - 36)/4 + 2
        )
    }
    
    private let newBadge = UIImageView(image: HomeAsset.imageNewBadge.image)
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DesignSystemAsset.Colors.gray70.color
        label.textAlignment = .center
        return label
    }()
    
    private let selectIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.Colors.pink100.color
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 1
        view.layer.borderColor = DesignSystemAsset.Colors.mainPink.color.cgColor
        view.isHidden = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            selectIndicator.isHidden = !isSelected
        }
    }
    
    override func setup() {
        backgroundColor = .clear
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            selectIndicator,
            categoryImage,
            categoryLabel,
            newBadge
        ])
        
        selectIndicator.snp.makeConstraints {
            $0.center.equalTo(categoryImage)
            $0.width.height.equalTo(58)
        }
        
        newBadge.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(14)
        }
        
        categoryImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(56)
            $0.height.equalTo(56)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(categoryImage.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(category: StoreFoodCategoryResponse) {
        categoryLabel.text = category.name
        categoryImage.setImage(urlString: category.imageUrl)
        newBadge.isHidden = !category.isNew
    }
}
