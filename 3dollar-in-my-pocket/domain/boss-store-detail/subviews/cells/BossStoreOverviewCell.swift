import UIKit

import Base
import NMapsMap
import Kingfisher

final class BossStoreOverviewCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreOverviewCell.self)"
    static let height: CGFloat = 484
    
    private var marker: NMFMarker?
    
    private let mapView = NMFMapView().then {
        $0.zoomLevel = 15
        $0.layer.cornerRadius = 10
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(R.image.ic_current_location_green(), for: .normal)
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
        $0.image = R.image.ic_star_green()
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
            self.shareButton
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
          make.right.equalToSuperview()
          make.bottom.equalTo(self.containerView.snp.top).offset(-20)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.mapView.snp.bottom).offset(-32)
            make.bottom.equalTo(self.shareButton)
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
        
        self.shareButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.top.equalTo(self.reviewIcon.snp.bottom).offset(5)
            make.height.equalTo(56)
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
    
    private func setMarker(latitude: Double, longitude: Double) {
        self.marker?.mapView = nil
        self.marker = NMFMarker()
        self.marker?.iconImage = NMFOverlayImage(name: "ic_marker_boss")
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
