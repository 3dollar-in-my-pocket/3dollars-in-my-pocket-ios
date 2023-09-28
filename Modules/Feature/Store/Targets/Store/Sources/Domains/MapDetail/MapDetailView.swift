import UIKit

import Common
import DesignSystem

import NMapsMap

final class MapDetailView: BaseView {
    private let topContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MapDetail.title
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 16)
        
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.withTintColor(Colors.gray100.color).resizeImage(scaledTo: 24), for: .normal)
        
        return button
    }()
    
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        
        mapView.positionMode = .direction
        mapView.zoomLevel = 15
        return mapView
    }()
    
    let navigationButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.MapDetail.navigationButton, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.mainPink.color
        
        return button
    }()
    
    private let buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        
        return view
    }()
    
    override func setup() {
        addSubViews([
            mapView,
            topContainer,
            titleLabel,
            closeButton,
            navigationButton,
            buttonBackgroundView
        ])
    }
    
    override func bindConstraints() {
        topContainer.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(56)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(topContainer).offset(-16)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        
        mapView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(topContainer.snp.bottom).offset(-10)
            $0.bottom.equalTo(navigationButton.snp.top)
        }
        
        buttonBackgroundView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        navigationButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(buttonBackgroundView.snp.top)
            $0.height.equalTo(64)
        }
    }
    
    func bind(location: CLLocation) {
        setMarket(location: location)
        moveCamera(location: location)
    }
    
    private func setMarket(location: CLLocation) {
        let marker = NMFMarker()
        marker.width = 32
        marker.height = 40
        marker.iconImage = NMFOverlayImage(image: Icons.markerFocuesd.image)
        
        let position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        
        marker.position = position
        marker.mapView = mapView
    }
    
    private func moveCamera(location: CLLocation) {
        let target = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        let cameraPosition = NMFCameraPosition(target, zoom: mapView.zoomLevel)
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
}
