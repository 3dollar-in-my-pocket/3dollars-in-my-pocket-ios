import UIKit

import Common
import DesignSystem

final class StoreDetailOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 376
    }
    
    let titleView = StoreDetailOverviewTitleView()
    
    let menuView = StoreDetailOverviewMenuView()
    
    override func setup() {
        addSubViews([
            titleView,
            menuView
        ])
    }
    
    override func bindConstraints() {
        titleView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(StoreDetailOverviewTitleView.Layout.height)
        }
        
        menuView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(titleView.snp.bottom).offset(20)
            $0.height.equalTo(StoreDetailOverviewMenuView.Layout.height)
            $0.right.equalToSuperview()
        }
    }
}
