import UIKit
import NMapsMap

class OverviewCell: BaseTableViewCell {
  
  static let registerId = "\(OverviewCell.self)"
  var marker = NMFMarker()
  
  let mapView = NMFMapView().then {
    $0.contentMode = .scaleAspectFill
    $0.positionMode = .direction
  }
  
  let currentLocationButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_current_location"), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.015
  }
  
  let overViewContainerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 8, height: 8)
    $0.layer.shadowOpacity = 0.04
  }
  
  let nicknameLabel = UILabel().then {
    $0.textColor = UIColor(r: 255, g: 161, b: 170)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let storeNameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 22)
    $0.textAlignment = .center
  }
  
  let distanceImage = UIImageView().then {
    $0.image = UIImage(named: "ic_near_filled")
  }
  
  let distanceLabel = UILabel().then {
    $0.textColor = .black
    $0.textAlignment = .right
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let starImage = UIImageView().then {
    $0.image = UIImage(named: "ic_star")
  }
  
  let starLabel = UILabel().then{
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let shareButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_share"), for: .normal)
    $0.setTitle("store_detail_share".localized, for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
  }
  
  let dividorView = UIView().then {
    $0.backgroundColor = UIColor(r: 208, g: 208, b: 208)
  }
  
  let transferButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_transfer"), for: .normal)
    $0.setTitle("store_detail_transfer".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 0, g: 80, b: 255), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.marker.mapView = nil
  }
  
  override func setup() {
    backgroundColor = .clear
    selectionStyle = .none
    contentView.isUserInteractionEnabled = false
    addSubViews(
      mapView, currentLocationButton, overViewContainerView, nicknameLabel,
      storeNameLabel, distanceImage, distanceLabel, starImage, starLabel,
      shareButton, transferButton, dividorView
    )
  }
  
  override func bindConstraints() {
    self.mapView.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.height.equalTo(UIScreen.main.bounds.height / 2.21)
    }
    
    self.currentLocationButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.overViewContainerView.snp.top).offset(-32)
    }
    
    self.overViewContainerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.mapView.snp.bottom).offset(-32)
      make.bottom.equalTo(self.dividorView)
        .offset(10)
      make.bottom.equalToSuperview()
    }
    
    self.nicknameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.overViewContainerView).offset(20)
    }
    
    self.storeNameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.left.equalTo(self.overViewContainerView).offset(16)
      make.right.equalTo(self.overViewContainerView).offset(-16)
      make.top.equalTo(self.nicknameLabel.snp.bottom).offset(8)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.right.equalTo(self.snp.centerX).offset(-13)
      make.top.equalTo(self.storeNameLabel.snp.bottom).offset(13)
    }
    
    self.distanceImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.distanceLabel)
      make.right.equalTo(self.distanceLabel.snp.left).offset(-4)
    }
    
    self.starImage.snp.makeConstraints { make in
      make.left.equalTo(self.snp.centerX).offset(8)
      make.centerY.equalTo(self.distanceLabel)
    }
    
    self.starLabel.snp.makeConstraints { make in
      make.left.equalTo(self.starImage.snp.right).offset(4)
      make.centerY.equalTo(self.distanceLabel)
    }
    
    self.shareButton.snp.makeConstraints { make in
      make.top.equalTo(self.distanceLabel.snp.bottom).offset(36)
      make.left.equalTo(self.overViewContainerView)
      make.right.equalTo(self.snp.centerX)
      make.height.equalTo(32)
    }
    
    self.transferButton.snp.makeConstraints { make in
      make.left.equalTo(self.snp.centerX)
      make.right.equalTo(self.overViewContainerView)
      make.centerY.equalTo(self.shareButton)
      make.height.equalTo(32)
    }
    
    self.dividorView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.shareButton)
      make.height.equalTo(32)
      make.width.equalTo(1)
    }
  }
  
  func bind(store: Store) {
    self.setNicknameBold(name: store.repoter.nickname)
    self.storeNameLabel.text = store.storeName
    self.distanceLabel.text = "\(store.distance)m"
    self.starLabel.text = "\(store.rating)점"
    self.setupMarker(latitude: store.latitude, longitude: store.longitude)
  }
  
  func moveToPosition(latitude: Double, longitude: Double) {
    let position = NMGLatLng(lat: latitude, lng: longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: position).then {
      $0.animation = .easeIn
    }
    
    self.mapView.moveCamera(cameraUpdate)
  }
  
  private func setNicknameBold(name: String?){
    if let name = name {
      let text = "\(name) \("store_detail_reporter".localized)"
      let attributedString = NSMutableAttributedString(string: text)
      
      attributedString.addAttribute(
        .font,
        value: UIFont(name: "AppleSDGothicNeo-Bold", size: 14) as Any,
        range: (text as NSString).range(of: name)
      )
      self.nicknameLabel.attributedText = attributedString
    }
  }
  
  private func setupMarker(latitude: Double, longitude: Double) {
    self.marker.mapView = nil
    let position = NMGLatLng(lat: latitude, lng: longitude)
    let iconImage = NMFOverlayImage(name: "ic_marker")
    self.marker = NMFMarker(position: position, iconImage: iconImage)
    let cameraUpdate = NMFCameraUpdate(scrollTo: position).then {
      $0.animation = .easeIn
    }
    
    self.mapView.moveCamera(cameraUpdate)
    marker.mapView = self.mapView
  }
}
