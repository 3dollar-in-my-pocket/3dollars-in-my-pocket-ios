import UIKit

import Common
import DesignSystem
import Model

final class CategorySelectionCell: BaseCollectionViewCell {
    static let size = CGSize(
        width: (UIScreen.main.bounds.width - 48 - 36)/4,
        height: (UIScreen.main.bounds.width - 48 - 36)/4 + 2
    )
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.font = Fonts.medium.font(size: 12)
        categoryLabel.textColor = Colors.gray70.color
        categoryLabel.textAlignment = .center
        return categoryLabel
    }()
    
    private let selectIndicator: UIView = {
        let selectIndicator = UIView()
        selectIndicator.backgroundColor = Colors.pink100.color
        selectIndicator.layer.cornerRadius = 28
        selectIndicator.layer.borderWidth = 1
        selectIndicator.layer.borderColor = Colors.mainPink.color.cgColor
        selectIndicator.isHidden = true
        return selectIndicator
    }()
    
    override var isSelected: Bool {
        didSet {
            selectIndicator.isHidden = !isSelected
        }
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            selectIndicator,
            categoryImage,
            categoryLabel
        ])
    }
    
    override func bindConstraints() {
        selectIndicator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        
        categoryImage.snp.makeConstraints {
            $0.center.equalTo(selectIndicator)
            $0.size.equalTo(52)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(categoryImage.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(category: PlatformStoreCategory) {
        categoryLabel.text = category.name
        categoryImage.setImage(urlString: category.imageUrl)
    }
}
