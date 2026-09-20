import UIKit

import Common
import DesignSystem
import Model

import NMapsMap

final class WriteDetailMapCell: BaseCollectionViewCell {
    var marker: NMFMarker?
    
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 166)
    }
    
    let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15
        mapView.layer.cornerRadius = 20
        mapView.layer.masksToBounds = true
        mapView.isUserInteractionEnabled = false
        return mapView
    }()
    
    let zoomButton: UIButton = {
        let zoomButton = UIButton()
        zoomButton.setImage(Icons.zoom.image.withRenderingMode(.alwaysTemplate), for: .normal)
        zoomButton.tintColor = Colors.gray50.color
        zoomButton.layer.cornerRadius = 18
        zoomButton.layer.borderColor = Colors.gray20.color.cgColor
        zoomButton.layer.borderWidth = 1
        zoomButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        zoomButton.layer.shadowColor = Colors.systemBlack.color.cgColor
        zoomButton.layer.shadowOpacity = 0.1
        zoomButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        zoomButton.backgroundColor = Colors.systemWhite.color
        return zoomButton
    }()
    
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
    
    func bind(location: LocationResponse) {
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
