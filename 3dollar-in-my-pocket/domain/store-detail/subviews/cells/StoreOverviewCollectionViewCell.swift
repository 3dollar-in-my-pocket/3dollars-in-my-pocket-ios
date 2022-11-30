import UIKit

import NMapsMap
import RxSwift
import RxCocoa

final class StoreOverviewCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(StoreOverviewCollectionViewCell.self)"
    static let height: CGFloat = UIScreen.main.bounds.height / 2.21 + 160
    
    private var marker = NMFMarker()
    
    private let mapView = NMFMapView().then {
        $0.contentMode = .scaleAspectFill
        $0.positionMode = .direction
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_location_pink"), for: .normal)
        $0.backgroundColor = .white
        $0.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.layer.borderColor = R.color.gray20()?.cgColor
        $0.layer.borderWidth = 1
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
        $0.layer.cornerRadius = 24
    }
    
    private let overViewContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 8, height: 8)
        $0.layer.shadowOpacity = 0.04
    }
    
    private let nicknameLabel = UILabel().then {
        $0.textColor = R.color.pink()
        $0.font = .medium(size: 14)
    }
    
    private let storeNameLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .extraBold(size: 22)
        $0.textAlignment = .center
    }
    
    private let distanceImage = UIImageView().then {
        $0.image = UIImage(named: "ic_near_filled_pink")
    }
    
    private let distanceLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .right
        $0.font = .medium(size: 14)
    }
    
    private let starImage = UIImageView().then {
        $0.image = UIImage(named: "ic_star")
    }
    
    private let starLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .medium(size: 14)
    }
    
    let shareButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_share"), for: .normal)
        $0.setTitle("store_detail_share".localized, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = R.color.gray20()
    }
    
    let bookmarkButton = UIButton().then {
        $0.setImage(R.image.ic_bookmark_off(), for: .normal)
        $0.setImage(R.image.ic_bookmark_on(), for: .selected)
        $0.setTitle(R.string.localization.store_detail_bookmark(), for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(R.color.red(), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
    }
    
    override func setup() {
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        self.addSubViews([
            self.mapView,
            self.currentLocationButton,
            self.overViewContainerView,
            self.nicknameLabel,
            self.storeNameLabel,
            self.distanceImage,
            self.distanceLabel,
            self.starImage,
            self.starLabel,
            self.shareButton,
            self.dividerView,
            self.bookmarkButton
        ])
    }
    
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2.21)
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.overViewContainerView.snp.top).offset(-32)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        self.overViewContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.mapView.snp.bottom).offset(-32)
            make.bottom.equalTo(self.shareButton).offset(10)
        }
        
        self.nicknameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.overViewContainerView).offset(20)
            make.height.equalTo(16)
        }
        
        self.storeNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(self.overViewContainerView).offset(16)
            make.right.equalTo(self.overViewContainerView).offset(-16)
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(10)
            make.height.equalTo(25)
        }
        
        self.distanceImage.snp.makeConstraints { make in
            make.top.equalTo(self.storeNameLabel.snp.bottom).offset(13)
            make.right.equalTo(self.distanceLabel.snp.left).offset(-4)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.distanceLabel.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(-13)
            make.centerY.equalTo(self.distanceImage)
        }
        
        self.starImage.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(8)
            make.centerY.equalTo(self.distanceLabel)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.starLabel.snp.makeConstraints { make in
            make.left.equalTo(self.starImage.snp.right).offset(4)
            make.centerY.equalTo(self.distanceLabel)
        }
        
        self.dividerView.snp.makeConstraints { make in
            make.centerX.equalTo(self.overViewContainerView)
            make.top.equalTo(self.distanceImage.snp.bottom).offset(30)
            make.height.equalTo(32)
            make.width.equalTo(1)
        }
        
        self.shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.dividerView)
            make.left.equalTo(self.overViewContainerView)
            make.right.equalTo(self.dividerView.snp.left)
            make.height.equalTo(32)
        }
        
        self.bookmarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.dividerView)
            make.left.equalTo(self.dividerView.snp.right)
            make.right.equalTo(self.overViewContainerView)
            make.height.equalTo(32)
        }
    }
    
    func bind(store: Store) {
        self.setNicknameBold(name: store.user.name)
        self.storeNameLabel.text = store.storeName
        self.distanceLabel.text = "\(store.distance)m"
        self.starLabel.text = "\(store.rating)점"
        self.moveToPosition(latitude: store.longitude, longitude: store.latitude)
        self.setupMarker(latitude: store.latitude, longitude: store.longitude)
        self.bookmarkButton.isSelected = store.isBookmarked
    }
    
    func moveToPosition(latitude: Double, longitude: Double) {
        let position = NMGLatLng(lat: latitude, lng: longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: position).then {
            $0.animation = .easeIn
        }
        
        self.mapView.moveCamera(cameraUpdate)
    }
    
    private func setNicknameBold(name: String?) {
        if let name = name {
            let text = "\(name) \("store_detail_reporter".localized)"
            let attributedString = NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: UIFont(name: "AppleSDGothicNeo-Bold", size: 14) as Any
                ]
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
        self.marker.mapView = self.mapView
    }
}
