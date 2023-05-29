import UIKit

import DesignSystem
import NMapsMap

final class WriteDetailMapCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 166)
    }
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 10
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    let zoomButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.zoom.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = DesignSystemAsset.Colors.gray50.color
        $0.layer.cornerRadius = 18
        $0.layer.borderColor = DesignSystemAsset.Colors.gray20.color.cgColor
        $0.layer.borderWidth = 1
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowColor = DesignSystemAsset.Colors.systemBlack.color.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    override func setup() {
        contentView.addSubViews([
            mapView,
            zoomButton
        ])
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-18)
        }
        
        zoomButton.snp.makeConstraints {
            $0.width.height.equalTo(36)
            $0.bottom.equalTo(mapView).offset(-8)
            $0.right.equalTo(mapView).offset(-8)
        }
    }
}
