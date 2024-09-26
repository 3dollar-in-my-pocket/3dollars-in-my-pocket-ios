import UIKit

import Common
import DesignSystem
import Model

import NMapsMap
import SnapKit

final class WriteAddressView: BaseView {
    private var markers: [NMFMarker] = []
    
    private let navigationView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.backgroundColor = Colors.systemWhite.color
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.writeAddressTitle
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image, for: .normal)
        
        return button
    }()
    
    let mapView: NMFMapView =  {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 17
        
        return mapView
    }()
    
    private let marker = UIImageView(image: Icons.markerFocuesd.image)
    
    let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.locationCurrent.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Colors.gray70.color
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.shadowColor = Colors.systemBlack.color.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray20.color.cgColor
        button.layer.cornerRadius = 23
        button.backgroundColor = Colors.systemWhite.color
        
        return button
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        return view
    }()
    
    private let addressTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.writeAddressBottomTitle
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    private let addressContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.gray10.color
        
        return view
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Colors.gray70.color
        label.font = Fonts.bold.font(size: 16)
        
        return label
    }()
    
    let addressButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.mainPink.color
        button.setTitle(Strings.writeAddressButton, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        
        return button
    }()
    
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
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
    
    func moveCamera(location: CLLocation) {
        let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        ))
        
        camera.animation = .easeIn
        mapView.moveCamera(camera)
    }
    
    func setNearStores(locations: [LocationResponse]) {
        clearMarkers()
        
        for location in locations {
            let marker = NMFMarker(
                position: NMGLatLng(lat: location.latitude, lng: location.longitude),
                iconImage: NMFOverlayImage(image: Icons.mappinUnfocused.image)
            )
            
            marker.width = 24
            marker.height = 24
            marker.mapView = mapView
            markers.append(marker)
        }
    }
    
    func setAddress(_ address: String) {
        addressLabel.text = address
    }
    
    private func clearMarkers() {
        for marker in markers {
            marker.mapView = nil
        }
    }
}
