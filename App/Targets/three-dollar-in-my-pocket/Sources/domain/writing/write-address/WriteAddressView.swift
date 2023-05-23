import UIKit

import DesignSystem
import RxSwift
import RxCocoa
import NMapsMap

final class WriteAddressView: BaseView {
    private var markers: [NMFMarker] = []
    
    private let navigationView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "write_title".localized
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    let closeButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.close.image, for: .normal)
    }
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 17
    }
    
    private let marker = UIImageView(image: DesignSystemAsset.Icons.markerFocuesd.image)
    
    let currentLocationButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.locationCurrent.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = DesignSystemAsset.Colors.gray70.color
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.shadowColor = DesignSystemAsset.Colors.systemBlack.color.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.1
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemAsset.Colors.gray20.color.cgColor
        $0.layer.cornerRadius = 23
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    private let bottomContainer = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private let addressTitleLabel = UILabel().then {
        $0.text = "write_address_bottom_title".localized
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    private let addressContainer = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.backgroundColor = DesignSystemAsset.Colors.gray10.color
    }
    
    let addressLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = DesignSystemAsset.Colors.gray70.color
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
    }
    
    let addressButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        $0.setTitle("write_address_button".localized, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        addSubViews([
            mapView,
            navigationView,
            closeButton,
            titleLabel,
            marker,
            currentLocationButton,
            bottomContainer,
            addressTitleLabel,
            addressContainer,
            addressLabel,
            addressButton
        ])
    }
    
    override func bindConstraints() {
        navigationView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(56)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(navigationView).offset(-16)
        }
        
        marker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(mapView).offset(20)
            make.width.equalTo(32)
            make.height.equalTo(40)
        }
        
        mapView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navigationView).offset(-10)
            make.bottom.equalTo(bottomContainer.snp.top).offset(10)
        }
        
        bottomContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(addressTitleLabel).offset(-26)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(bottomContainer.snp.top).offset(-28)
            make.width.equalTo(46)
            make.height.equalTo(46)
        }
        
        addressButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(48)
        }
        
        addressContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(addressButton.snp.top).offset(-21)
            make.height.equalTo(48)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(addressContainer)
            make.left.equalTo(addressContainer).offset(8)
            make.right.equalTo(addressContainer).offset(-8)
        }
        
        addressTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(addressContainer.snp.top).offset(-20)
        }
    }
    
    fileprivate func moveCamera(latitude: Double, longitude: Double) {
        let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
            lat: latitude,
            lng: longitude
        ))
        
        camera.animation = .easeIn
        mapView.moveCamera(camera)
    }
    
    fileprivate func setNearStores(stores: [Store]) {
        clearMarkers()
        
        for store in stores {
            let marker = NMFMarker(
                position: NMGLatLng(lat: store.latitude, lng: store.longitude),
                iconImage: NMFOverlayImage(name: "ic_marker_store_off")
            )
            
            marker.width = 24
            marker.height = 24
            marker.mapView = mapView
            markers.append(marker)
        }
    }
    
    private func clearMarkers() {
        for marker in markers {
            marker.mapView = nil
        }
    }
}

extension Reactive where Base: WriteAddressView {
    var cameraPosition: Binder<(Double, Double)> {
        return Binder(self.base) { view, position in
            view.moveCamera(
                latitude: position.0,
                longitude: position.1
            )
        }
    }
    
    var nearStores: Binder<[Store]> {
        return Binder(self.base) { view, stores in
            view.setNearStores(stores: stores)
        }
    }
}
