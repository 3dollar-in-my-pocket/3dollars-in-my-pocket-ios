import UIKit
import NMapsMap

class WriteAddressView: BaseView {
  
  let navigationView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.04
    $0.backgroundColor = .white
  }
  
  let titleLabel = UILabel().then {
    $0.text = "write_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = .black
  }
  
  let closeButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_close"), for: .normal)
  }
  
  let mapView = NMFMapView()
  
  let marker = UIImageView().then {
    $0.image = UIImage(named: "ic_marker")
  }
  
  let currentLocationButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_current_location"), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.015
  }
  
  let bottomContainer = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
  }
  
  let addressTitleLabel = UILabel().then {
    $0.text = "write_address_bottom_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
    $0.textColor = .black
  }
  
  let addressContainer = UIView().then {
    $0.layer.cornerRadius = 8
    $0.layer.masksToBounds = true
    $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
  let addressLabel = UILabel().then {
    $0.text = "주소주소"
    $0.textAlignment = .center
    $0.textColor = UIColor(r: 28, g: 28, b: 28)
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
  }
  
  let addressButton = UIButton().then {
    $0.backgroundColor = UIColor(r: 255, g: 92, b: 67)
    $0.setTitle("write_address_button".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.layer.cornerRadius = 24
    $0.layer.masksToBounds = true
  }
  
  
  override func setup() {
    backgroundColor = .white
    addSubViews(
      mapView, navigationView, closeButton, titleLabel,
      marker, currentLocationButton, bottomContainer, addressTitleLabel, addressContainer,
      addressLabel, addressButton
    )
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { (make) in
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
  
  func moveCamera(latitude: Double, longitude: Double) {
    let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
      lat: latitude,
      lng: longitude
    ))
    
    camera.animation = .easeIn
    self.mapView.moveCamera(camera)
  }
}
