import UIKit

import Common
import DesignSystem
import Model
import NMapsMap
import CombineCocoa

final class StoreDetailMapCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 172
    }
    
    private var marker: NMFMarker?
    
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.zoomLevel = 15
        mapView.positionMode = .direction
        mapView.layer.cornerRadius = 20
        mapView.layer.masksToBounds = true
        mapView.isUserInteractionEnabled = false
        return mapView
    }()
    
    private let addressButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.backgroundColor = Colors.gray95.color.withAlphaComponent(0.6)
        button.setImage(
            Icons.copy.image.withTintColor(Colors.systemWhite.color).resizeImage(scaledTo: 16),
            for: .normal
        )
        button.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        
        return button
    }()
    
    private let zoomButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.systemWhite.color
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.layer.borderColor = Colors.gray20.color.cgColor
        button.layer.borderWidth = 1
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowColor = Colors.systemBlack.color.withAlphaComponent(0.1).cgColor
        button.setImage(Icons.zoom.image.withTintColor(Colors.gray50.color), for: .normal)
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()
    
    override func prepareForReuse() {
        marker?.mapView = nil
    }
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            mapView,
            addressButton,
            zoomButton
        ])
        
        mapView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }
        
        addressButton.snp.makeConstraints {
            $0.leading.equalTo(mapView).offset(8)
            $0.bottom.equalTo(mapView).offset(-8)
            $0.height.equalTo(34)
        }
        
        zoomButton.snp.makeConstraints {
            $0.trailing.equalTo(mapView).offset(-8)
            $0.bottom.equalTo(mapView).offset(-8)
            $0.size.equalTo(36)
        }
    }
    
    func bind(viewModel: StoreDetailMapCellViewModel) {
        bindData(viewModel.output.data)
        
        addressButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAddress)
            .store(in: &cancellables)
        
        zoomButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapMapDetail)
            .store(in: &cancellables)
    }
    
    private func bindData(_ data: StoreMapSectionResponse) {
        addressButton.setTitle(data.addressName?.text, for: .normal)
        setMarket(location: data.location)
        moveCamera(location: data.location)
    }
    
    private func moveCamera(location: LocationResponse) {
        let target = NMGLatLng(lat: location.latitude, lng: location.longitude)
        let cameraPosition = NMFCameraPosition(target, zoom: mapView.zoomLevel)
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    private func setMarket(location: LocationResponse) {
        marker = NMFMarker()
        marker?.width = 32
        marker?.height = 40
        marker?.iconImage = NMFOverlayImage(image: Icons.markerFocuesd.image)
        
        let position = NMGLatLng(lat: location.latitude, lng: location.longitude)
        
        marker?.position = position
        marker?.mapView = mapView
    }
}
