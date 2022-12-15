import UIKit

import RxSwift
import RxCocoa
import NMapsMap
import Kingfisher

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    let storeTypeButton = StoreTypeButton()
  
    let addressButton = AddressButton()
    
    let tooltipView = FoodTruckTooltipView().then {
        $0.isHidden = true
    }
    
    let categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.estimatedItemSize = HomeCategoryCollectionViewCell.itemSize
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 24)
        $0.contentInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.clipsToBounds = false
        $0.register(
            HomeCategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: HomeCategoryCollectionViewCell.registerId
        )
    }
  
    let researchButton = UIButton().then {
        $0.setTitle(R.string.localization.home_research(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .semiBold(size: 14)
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        $0.backgroundColor = R.color.red()
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.08
        $0.alpha = 0.0
    }
  
    let storeCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = HomeStoreFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 17
        layout.itemSize = HomeStoreCell.itemSize
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.register([
            HomeStoreCell.self,
            HomeEmptyStoreCell.self,
            HomeAdvertisementCell.self
        ])
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(R.image.ic_location_pink(), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = R.color.gray20()?.cgColor
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .white
        $0.accessibilityLabel = "현재 위치"
    }
  
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.mapView,
            self.researchButton,
            self.storeTypeButton,
            self.addressButton,
            self.categoryCollectionView,
            self.storeCollectionView,
            self.currentLocationButton,
            self.tooltipView
        ])
    }
  
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.storeTypeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.width.equalTo(94)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(9)
        }
        
        self.addressButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.storeTypeButton)
            make.right.equalToSuperview().offset(-24)
            make.left.equalTo(self.storeTypeButton.snp.right).offset(8)
        }
        
        self.tooltipView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.top.equalTo(self.storeTypeButton.snp.bottom).offset(6)
        }
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.storeTypeButton.snp.bottom).offset(12)
            make.right.equalToSuperview()
            make.height.equalTo(HomeCategoryCollectionViewCell.itemSize.height)
        }
        
        self.researchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.categoryCollectionView)
            make.height.equalTo(40)
        }
        
        self.storeCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(124)
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.storeCollectionView.snp.top).offset(-33)
        }
    }
  
    fileprivate func setHiddenResearchButton(isHidden: Bool) {
        UIView.transition(
            with: self.researchButton,
            duration: 0.3,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.researchButton.transform = isHidden ? .identity : .init(translationX: 0, y: 56)
            self?.researchButton.alpha = isHidden ? 0.0 : 1.0
        }
    }
    
    fileprivate func moveCamera(position: CLLocation) {
        if self.mapView.positionMode == .disabled {
            self.mapView.positionMode = .direction
        }
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(
                lat: position.coordinate.latitude,
                lng: position.coordinate.longitude
            ),
            zoom: self.mapView.zoomLevel
        )
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        self.mapView.moveCamera(cameraUpdate)
    }
    
    fileprivate func setStoreType(storeType: StoreType) {
        if storeType == .foodTruck {
            self.currentLocationButton.setImage(R.image.ic_location_green(), for: .normal)
        } else {
            self.currentLocationButton.setImage(R.image.ic_location_pink(), for: .normal)
        }
    }
    
    fileprivate func setMarker(advertisement: Advertisement) {
        guard let url = URL(string: advertisement.imageUrl) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let result):
                self?.mapView.locationOverlay.icon = NMFOverlayImage(image: result.image)
                self?.mapView.locationOverlay.iconWidth = CGFloat(advertisement.imageWidth)
                self?.mapView.locationOverlay.iconHeight = CGFloat(advertisement.imageHeight)
                
            case .failure:
                self?.mapView.locationOverlay.icon = NMFOverlayImage(name: "")
            }
        }
    }
}


extension Reactive where Base: HomeView {
    var isResearchButtonHidden: Binder<Bool> {
        return Binder(self.base) { view, isHidden in
            view.setHiddenResearchButton(isHidden: isHidden)
        }
    }
    
    var cameraPosition: Binder<CLLocation> {
        return Binder(self.base) { view, cameraPosition in
            view.moveCamera(position: cameraPosition)
        }
    }
    
    var storeType: Binder<StoreType> {
        return Binder(self.base) { view, storeType in
            view.setStoreType(storeType: storeType)
            view.storeTypeButton.rx.storeType.onNext(storeType)
        }
    }
    
    var isTooltipHidden: Binder<Bool> {
        return base.tooltipView.rx.isTooltipHidden
    }
    
    var advertisementMarker: Binder<Advertisement> {
        return Binder(self.base) { view, advertisement in
            view.setMarker(advertisement: advertisement)
        }
    }
}
