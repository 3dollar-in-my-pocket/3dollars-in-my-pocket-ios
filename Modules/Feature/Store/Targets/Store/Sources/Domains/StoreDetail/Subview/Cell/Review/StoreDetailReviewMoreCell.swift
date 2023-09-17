import UIKit

import Common
import DesignSystem

final class StoreDetailReviewMoreCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 46
    }
    
    let moreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.titleLabel?.textAlignment = .center
        
        return button
    }()
    
    override func setup() {
        contentView.addSubViews([
            moreButton
        ])
    }
    
    override func bindConstraints() {
        moreButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().priority(.high)
            $0.height.equalTo(Layout.height)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(_ totalCount: Int) {
        moreButton.setTitle(Strings.StoreDetail.Review.moreFormat(totalCount - 3), for: .normal)
    }
}
