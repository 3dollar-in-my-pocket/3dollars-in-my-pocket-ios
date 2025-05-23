import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class FeedCellCategoryView: BaseView {
    enum Layout {
        static let height: CGFloat = 26
    }
    
    private let categoryLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 12, rightInset: 12)
        label.layer.cornerRadius = 13
        label.layer.masksToBounds = true
        label.font = Fonts.bold.font(size: 12)
        return label
    }()
    
    private let updatedAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.text = "20분 전"
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            categoryLabel,
            updatedAtLabel
        ])
        
        categoryLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(updatedAtLabel.snp.leading).offset(-12)
        }
        
        updatedAtLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(categoryLabel)
        }
    }
    
    func bind(category: FeedCategoryResponse, updatedAt: String) {
        categoryLabel.setSDText(category.name)
        categoryLabel.backgroundColor = UIColor(hex: category.style.backgroundColor)
        updatedAtLabel.text = updatedAt.createdAtFormatted
    }
}
