import UIKit

import NMapsMap
import Kingfisher

final class BossStoreOverviewCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreOverviewCell.self)"
    static let height: CGFloat = 484
    
    private var marker: NMFMarker?
    
    private let mapView = NMFMapView().then {
        $0.zoomLevel = 15
        $0.layer.cornerRadius = 10
        $0.positionMode = .direction
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(R.image.ic_location_green(), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = R.color.gray20()?.cgColor
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 8, height: 8)
        $0.layer.shadowOpacity = 0.04
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = R.color.gray100()
        $0.textAlignment = .center
    }
    
    private let distanceIcon = UIImageView().then {
        $0.image = R.image.ic_near_filled_green()
    }
    
    private let distanceLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = R.color.black()
    }
    
    private let reviewIcon = UIImageView().then {
        $0.image = R.image.ic_review_green()
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = R.color.black()
        $0.textAlignment = .left
    }
    
    let shareButton = UIButton().then {
        $0.setImage(R.image.ic_share(), for: .normal)
        $0.setTitle(R.string.localization.boss_store_share(), for: .normal)
        $0.setTitleColor(R.color.black(), for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
        $0.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = R.color.gray20()
    }
    
    let bookmarkButton = UIButton().then {
        $0.setImage(R.image.ic_bookmark_off()?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setImage(R.image.ic_bookmark_on()?.withRenderingMode(.alwaysTemplate), for: .selected)
        $0.setTitle(R.string.localization.store_detail_bookmark(), for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(R.color.green(), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.tintColor = R.color.green()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.categoryStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.currentLocationButton,
            self.containerView,
            self.categoryStackView,
            self.nameLabel,
            self.distanceIcon,
            self.distanceLabel,
            self.reviewIcon,
            self.reviewCountLabel,
            self.shareButton,
            self.dividerView,
            self.bookmarkButton
        ])
    }
    
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(346)
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.containerView.snp.top).offset(-32)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.mapView.snp.bottom).offset(-32)
            make.bottom.equalTo(self.shareButton).offset(10)
        }
        
        self.categoryStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.containerView).offset(20)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.categoryStackView.snp.bottom).offset(8)
        }
        
        self.reviewIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.reviewCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.reviewIcon)
            make.left.equalTo(self.reviewIcon.snp.right).offset(4)
            make.right.equalTo(self.containerView).offset(-24)
        }
        
        self.distanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.reviewIcon)
            make.right.equalTo(self.reviewIcon.snp.left).offset(-4)
        }
        
        self.distanceIcon.snp.makeConstraints { make in
            make.right.equalTo(self.distanceLabel.snp.left).offset(-4)
            make.centerY.equalTo(self.reviewIcon)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.dividerView.snp.makeConstraints { make in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.distanceIcon.snp.bottom).offset(30)
            make.height.equalTo(32)
            make.width.equalTo(1)
        }
        
        self.shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.dividerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.dividerView.snp.left)
            make.height.equalTo(32)
        }
        
        self.bookmarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.dividerView)
            make.left.equalTo(self.dividerView.snp.right)
            make.right.equalTo(self.containerView)
            make.height.equalTo(32)
        }
    }
    
    func bind(store: BossStore) {
        if let location = store.location {
            self.setMarker(latitude: location.latitude, longitude: location.longitude)
        }
        self.setCategories(categories: store.categories)
        self.nameLabel.text = store.name
        self.distanceLabel.text = "\(store.distance)m"
        self.reviewCountLabel.text = "리뷰 \(store.feedbackCount)개"
    }
    
    func moveCamera(location: CLLocation) {
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
    
    private func setMarker(latitude: Double, longitude: Double) {
        self.marker?.mapView = nil
        self.marker = NMFMarker()
        self.marker?.iconImage = NMFOverlayImage(name: "ic_marker_boss_open_selected")
        self.marker?.width = 30
        self.marker?.height = 40
        self.marker?.position = NMGLatLng(lat: latitude, lng: longitude)
        self.marker?.mapView = self.mapView
        self.mapView.moveCamera(
            NMFCameraUpdate(position: .init(.init(lat: latitude, lng: longitude), zoom: 15))
        )
    }
    
    private func setCategories(categories: [Categorizable]) {
        for category in categories {
            let categoryLagel = PaddingLabel(
                topInset: 4,
                bottomInset: 4,
                leftInset: 8,
                rightInset: 8
            ).then {
                $0.backgroundColor = UIColor(r: 0, g: 198, b: 103, a: 0.1)
                $0.textColor = R.color.green()
                $0.layer.cornerRadius = 8
                $0.text = category.name
                $0.font = .regular(size: 14)
                $0.layer.masksToBounds = true
                $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
            
            self.categoryStackView.addArrangedSubview(categoryLagel)
        }
    }
}
