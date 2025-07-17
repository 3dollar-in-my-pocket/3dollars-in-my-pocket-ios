import UIKit

import Common
import Model
import DesignSystem

final class WriteDetailCategorySectionHeaderView: BaseCollectionViewReusableView {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 48)
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.textAlignment = .left
        return label
    }()
    
    override func setup() {
        addSubview(titleLabel)
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func setClassification(_ classification: StoreCategoryClassificationResponse) {
        titleLabel.text = classification.description
    }
} 
