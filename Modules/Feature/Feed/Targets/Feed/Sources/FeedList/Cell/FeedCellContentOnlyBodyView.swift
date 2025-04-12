import UIKit

import Common
import DesignSystem
import Model

final class FeedCellContentOnlyBodyView: BaseView {
    enum Layout {
        static let height: CGFloat = 36
    }
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    override func setup() {
        addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    func bind(body: ContentOnlyFeedBodyResponse) {
        contentLabel.setUiText(body.content)
        backgroundColor = UIColor(hex: body.style.backgroundColor)
    }
}
