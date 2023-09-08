import UIKit

import Common
import DesignSystem
import NMapsMap

final class StoreDetailOverviewMapView: BaseView {
    enum Layout {
        static let mapHeight: CGFloat = 140
    }
    
    let mapView = NMFMapView().then {
        $0.zoomLevel = 15
        $0.positionMode = .direction
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    private let marker = UIImageView(image: Icons.markerFocuesd.image)
    
    private let addressLabel = PaddingLabel(
        topInset: 8,
        bottomInset: 8,
        leftInset: 16,
        rightInset: 16
    ).then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.systemWhite.color
        $0.text = "서울특별시 관악구 독립문로 14길"
        $0.layer.cornerRadius = 17
        $0.layer.masksToBounds = true
        $0.backgroundColor = Colors.gray95.color.withAlphaComponent(0.6)
    }
    
    private let zoomButton = UIButton().then {
        $0.backgroundColor = Colors.systemWhite.color
        $0.layer.cornerRadius = 18
        $0.layer.masksToBounds = true
        $0.layer.borderColor = Colors.gray20.color.cgColor
        $0.layer.borderWidth = 1
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowColor = Colors.systemBlack.color.withAlphaComponent(0.1).cgColor
        $0.setImage(Icons.zoom.image.withTintColor(Colors.gray50.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    override func setup() {
        addSubViews([
            mapView,
            marker,
            addressLabel,
            zoomButton
        ])
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(Layout.mapHeight)
        }
        
        marker.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(40)
            $0.center.equalTo(mapView)
        }
        
        addressLabel.snp.makeConstraints {
            $0.left.equalTo(mapView).offset(8)
            $0.bottom.equalTo(mapView).offset(-8)
            $0.height.equalTo(34)
        }
        
        zoomButton.snp.makeConstraints {
            $0.right.equalTo(mapView).offset(-8)
            $0.bottom.equalTo(mapView).offset(-8)
            $0.size.equalTo(36)
        }
    }
}
