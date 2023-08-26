import UIKit

import DesignSystem
import NMapsMap

final class WriteDetailMapCell: BaseCollectionViewCell {
    var marker: NMFMarker?
    
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 166)
    }
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    let zoomButton = UIButton().then {
        $0.setImage(Icons.zoom.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.gray50.color
        $0.layer.cornerRadius = 18
        $0.layer.borderColor = Colors.gray20.color.cgColor
        $0.layer.borderWidth = 1
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowColor = Colors.systemBlack.color.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.backgroundColor = Colors.systemWhite.color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        marker?.mapView = nil
    }
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
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
    
    func bind(location: Location) {
        marker = NMFMarker()
        let targetLocation = NMGLatLng(lat: location.latitude, lng: location.longitude)
        marker?.position = targetLocation
        marker?.iconImage = NMFOverlayImage(image: Icons.markerFocuesd.image)
        marker?.width = 32
        marker?.height = 40
        marker?.mapView = mapView
        
        let cameraUpdate = NMFCameraUpdate(position: .init(targetLocation, zoom: 15))
        mapView.moveCamera(cameraUpdate)
    }
}
