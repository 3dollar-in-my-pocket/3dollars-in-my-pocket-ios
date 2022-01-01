import UIKit

import RxSwift
import RxCocoa
import NMapsMap

final class WriteAddressView: BaseView {
    private let navigationView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.04
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = R.string.localization.write_title()
        $0.font = .semiBold(size: 16)
        $0.textColor = .black
    }
    
    let closeButton = UIButton().then {
        $0.setImage(R.image.ic_close(), for: .normal)
    }
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 17
    }
    
    private let marker = UIImageView().then {
        $0.image = R.image.ic_marker()
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(R.image.ic_current_location(), for: .normal)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.015
    }
    
    private let bottomContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private let addressTitleLabel = UILabel().then {
        $0.text = R.string.localization.write_address_bottom_title()
        $0.font = .bold(size: 20)
        $0.textColor = .black
    }
    
    private let addressContainer = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.backgroundColor = R.color.gray0()
    }
    
    let addressLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = R.color.gray100()
        $0.font = .semiBold(size: 16)
    }
    
    let addressButton = UIButton().then {
        $0.backgroundColor = R.color.red()
        $0.setTitle(R.string.localization.write_address_button(), for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.mapView,
            self.navigationView,
            self.closeButton,
            self.titleLabel,
            self.marker,
            self.currentLocationButton,
            self.bottomContainer,
            self.addressTitleLabel,
            self.addressContainer,
            self.addressLabel,
            self.addressButton
        ])
    }
    
    override func bindConstraints() {
        self.navigationView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.navigationView).offset(-22)
        }
        
        self.marker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.mapView.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(40)
        }
        
        self.mapView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(50)
            make.bottom.equalTo(self.bottomContainer.snp.top).offset(10)
        }
        
        self.bottomContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.addressTitleLabel).offset(-32)
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.bottomContainer.snp.top).offset(-27)
        }
        
        self.addressButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(48)
        }
        
        self.addressContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.addressButton.snp.top).offset(-29)
            make.height.equalTo(48)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.addressContainer)
            make.left.equalTo(self.addressContainer).offset(8)
            make.right.equalTo(self.addressContainer).offset(-8)
        }
        
        self.addressTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(self.addressContainer.snp.top).offset(-20)
        }
    }
    
    fileprivate func moveCamera(latitude: Double, longitude: Double) {
        let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
            lat: latitude,
            lng: longitude
        ))
        
        camera.animation = .easeIn
        self.mapView.moveCamera(camera)
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
}
