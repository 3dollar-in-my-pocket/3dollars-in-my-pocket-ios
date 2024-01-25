import UIKit

import Common
import Model
import DesignSystem

final class FaqCategoryCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateSize(category: FaqCategoryResponse) -> CGSize {
            let title = NSString(string: category.description)
            let textSize = title.size(withAttributes: [
                .font: Fonts.medium.font(size: 12)
            ])
            
            return CGSize(width: textSize.width + 34, height: 34)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.backgroundColor = isSelected ? Colors.mainPink.color : .clear
            titleLabel.textColor = isSelected ? Colors.systemWhite.color : Colors.gray70.color
        }
    }
    
    private let titleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 8, bottomInset: 8, leftInset: 16, rightInset: 16)
        
        label.textColor = Colors.gray70.color
        label.font = Fonts.medium.font(size: 12)
        label.layer.borderColor = Colors.gray90.color.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    override func setup() {
        addSubViews([
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().priority(.high)
        }
    }
    
    func bind(category: FaqCategoryResponse) {
        titleLabel.text = category.description
    }
}
