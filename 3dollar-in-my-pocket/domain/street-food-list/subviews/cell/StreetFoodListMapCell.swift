import UIKit

import Base
import RxSwift
import RxCocoa
import NMapsMap

final class StreetFoodListMapCell: BaseCollectionViewCell {
    static let registerId = "\(StreetFoodListMapCell.self)"
    static let height: CGFloat = 346
    private var markers: [NMFMarker] = []
    
    let mapView = NMFMapView().then {
        $0.positionMode = .compass
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(R.image.ic_location_pink(), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = R.color.gray20()?.cgColor
        $0.layer.cornerRadius = 24
        $0.backgroundColor = .white
    }
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.currentLocationButton
        ])
    }
    
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
    }
    
    fileprivate func moveCamera(location: CLLocation) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude
            ),
            zoom: self.mapView.zoomLevel
        )
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        self.mapView.moveCamera(cameraUpdate)
    }
    
    private func setMarkers(storeCellTypes: [StoreCellType]) {
        self.clearMarkers()
        
        for cellType in storeCellTypes {
            if case .store(let store) = cellType {
                if let store = store as? Store {
                    let marker = NMFMarker()
                    
                    marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
                    marker.iconImage = NMFOverlayImage(name: "ic_marker_store_on")
                    marker.mapView = self.mapView
                    self.markers.append(marker)
                }
            }
        }
    }
    
    private func clearMarkers() {
        for marker in self.markers {
            marker.mapView = nil
        }
    }
}

extension Reactive where Base: StreetFoodListMapCell {
    var cameraPosition: Binder<CLLocation> {
        return Binder(self.base) { view, cameraPosition in
            view.moveCamera(location: cameraPosition)
        }
    }
}
