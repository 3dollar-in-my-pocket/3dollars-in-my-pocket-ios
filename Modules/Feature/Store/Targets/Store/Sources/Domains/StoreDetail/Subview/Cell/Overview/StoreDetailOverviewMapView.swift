import UIKit

import Common
import DesignSystem
import Model
import NMapsMap

final class StoreDetailOverviewMapView: BaseView {
    enum Layout {
        static let mapHeight: CGFloat = 140
    }
    
    var marker: NMFMarker?
    
    let mapView = NMFMapView().then {
        $0.zoomLevel = 15
        $0.positionMode = .direction
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    private let addressLabel = PaddingLabel(
        topInset: 8,
        bottomInset: 8,
        leftInset: 16,
        rightInset: 16
    ).then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.systemWhite.color
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
    
    func prepareForReuse() {
        marker?.mapView = nil
    }
    
    func bind(location: Location, address: String) {
        addressLabel.text = address
        
        setMarket(location: location)
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        moveCamera(location: location)
    }
    
    private func moveCamera(location: CLLocation) {
        let target = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        let cameraPosition = NMFCameraPosition(target, zoom: mapView.zoomLevel)
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    private func setMarket(location: Location) {
        marker = NMFMarker()
        marker?.width = 32
        marker?.height = 40
        marker?.iconImage = NMFOverlayImage(image: Icons.markerFocuesd.image)
        
        let position = NMGLatLng(lat: location.latitude, lng: location.longitude)
        
        marker?.position = position
        marker?.mapView = mapView
    }
}
