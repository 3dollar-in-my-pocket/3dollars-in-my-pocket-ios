import UIKit

import Common
import DesignSystem

final class StoreDetailOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 344
    }
    
    let titleView = StoreDetailOverviewTitleView()
    
    let menuView = StoreDetailOverviewMenuView()
    
    let mapView = StoreDetailOverviewMapView()
    
    override func setup() {
        addSubViews([
            titleView,
            menuView,
            mapView
        ])
    }
    
    override func bindConstraints() {
        titleView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.right.equalToSuperview()
            $0.height.equalTo(StoreDetailOverviewTitleView.Layout.height)
        }
        
        menuView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(titleView.snp.bottom).offset(20)
            $0.height.equalTo(StoreDetailOverviewMenuView.Layout.height)
            $0.right.equalToSuperview()
        }
        
        mapView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(menuView.snp.bottom).offset(24)
            $0.right.equalToSuperview()
        }
    }
}
