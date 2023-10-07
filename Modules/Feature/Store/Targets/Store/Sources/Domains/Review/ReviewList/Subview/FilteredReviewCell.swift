import UIKit

import Common
import DesignSystem

final class FilteredReviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = Colors.gray10.color
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ReviewList.filtered
        label.textColor = Colors.gray50.color
        label.font = Fonts.regular.font(size: 14)
        
        return label
    }()
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(Layout.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.centerY.equalTo(containerView)
        }
    }
}
