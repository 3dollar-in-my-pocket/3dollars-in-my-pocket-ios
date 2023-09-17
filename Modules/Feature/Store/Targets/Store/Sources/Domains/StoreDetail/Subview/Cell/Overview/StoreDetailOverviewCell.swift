import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 376
    }
    
    let titleView = StoreDetailOverviewTitleView()
    
    let menuView = StoreDetailOverviewMenuView()
    
    let mapView = StoreDetailOverviewMapView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.prepareForReuse()
        mapView.prepareForReuse()
    }
    
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
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    func bind(_ overview: StoreDetailOverview) {
        titleView.bind(overview)
        mapView.bind(location: overview.location, address: overview.address)
    }
}
