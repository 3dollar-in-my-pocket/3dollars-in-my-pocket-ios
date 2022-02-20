import UIKit

import RxSwift
import RxCocoa
import NMapsMap

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
  
    let addressContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.08
    }
  
    let addressButton = UIButton().then {
        $0.titleLabel?.font = .semiBold(size: 16)
        $0.setImage(R.image.ic_arrow_bottom_black(), for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        $0.setTitleColor(.black, for: .normal)
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
        $0.setImage(R.image.ic_current_location(), for: .normal)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
        $0.accessibilityLabel = "현재 위치"
    }
    
    let tossButton = UIButton().then {
        $0.setImage(R.image.ic_toss(), for: .normal)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
        $0.accessibilityLabel = "토스 송금하기"
    }
  
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.mapView,
            self.researchButton,
            self.addressContainerView,
            self.addressButton,
            self.storeCollectionView,
            self.currentLocationButton,
            self.tossButton
        ])
    }
  
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.addressContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(7)
            make.height.equalTo(56)
        }
        
        self.addressButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.addressContainerView)
        }
        
        self.researchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.addressContainerView)
            make.height.equalTo(40)
        }
        
        self.storeCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(124)
        }
        
        self.tossButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.storeCollectionView.snp.top).offset(-40)
        }
        
        self.currentLocationButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.tossButton)
            make.bottom.equalTo(self.tossButton.snp.top).offset(-12)
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
}
