import UIKit

import Common
import DesignSystem
import Model

import NMapsMap
import SnapKit
import Then

final class HomeView: BaseView {
    private let homeViewModel: HomeViewModel
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    let addressButton = AddressButton()
    
    lazy var homeFilterCollectionView = HomeFilterCollectionView(homeViewModel: homeViewModel)
    
//    let categoryFilterButton = CategoryFilterButton()
//    
//    let sortingButton = SortingButton()
//    
//    let onlyBossToggleButton = OnlyBossToggleButton()
    
    let researchButton = UIButton().then {
        $0.setTitle(HomeStrings.homeResearchButton, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.cornerRadius = 17
        $0.alpha = 0.0
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.locationCurrent.image.withTintColor(DesignSystemAsset.Colors.systemBlack.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemAsset.Colors.gray20.color.cgColor
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = DesignSystemAsset.Colors.systemBlack.color.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.1
    }
    
    let listViewButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.list.image.resizeImage(scaledTo: 16).withTintColor(DesignSystemAsset.Colors.systemWhite.color), for: .normal)
        $0.setTitle(HomeStrings.homeListViewButton, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.layer.cornerRadius = 20
        $0.backgroundColor = DesignSystemAsset.Colors.gray80.color
        $0.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        $0.contentEdgeInsets = .init(top: 11, left: 12, bottom: 11, right: 16)
        $0.layer.shadowColor = DesignSystemAsset.Colors.systemBlack.color.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.1
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = false
    }
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubViews([
            mapView,
            researchButton,
            addressButton,
            homeFilterCollectionView,
//            categoryFilterButton,
//            sortingButton,
//            onlyBossToggleButton,
            currentLocationButton,
            listViewButton,
            collectionView
        ])
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
        
        addressButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        homeFilterCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(addressButton.snp.bottom)
            $0.right.equalToSuperview()
            $0.height.equalTo(60)
        }
        
//        categoryFilterButton.snp.makeConstraints {
//            $0.left.equalToSuperview().offset(20)
//            $0.top.equalTo(addressButton.snp.bottom).offset(14)
//            $0.height.equalTo(34)
//        }
//        
//        sortingButton.snp.makeConstraints {
//            $0.left.equalTo(categoryFilterButton.snp.right).offset(10)
//            $0.centerY.equalTo(categoryFilterButton)
//            $0.height.equalTo(34)
//        }
//        
//        onlyBossToggleButton.snp.makeConstraints {
//            $0.left.equalTo(sortingButton.snp.right).offset(10)
//            $0.centerY.equalTo(categoryFilterButton)
//            $0.height.equalTo(34)
//        }
        
        researchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(homeFilterCollectionView)
            make.height.equalTo(34)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalTo(collectionView.snp.top).offset(-16)
            $0.width.height.equalTo(40)
        }
        
        listViewButton.snp.makeConstraints {
            $0.centerY.equalTo(currentLocationButton)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-15)
            $0.height.equalTo(HomeStoreCardCell.Layout.size.height)
        }
    }
    
    func setHiddenResearchButton(isHidden: Bool) {
        UIView.transition(
            with: researchButton,
            duration: 0.3,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.researchButton.transform = isHidden ? .identity : .init(translationX: 0, y: 56)
            self?.researchButton.alpha = isHidden ? 0.0 : 1.0
        }
    }
    
    func moveCamera(location: CLLocation) {
        let target = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        let cameraPosition = NMFCameraPosition(target, zoom: mapView.zoomLevel)
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    func setAdvertisementMarker(_ advertisement: Advertisement) {
        guard let urlString = advertisement.imageUrl,
              let url = URL(string: urlString) else { return }
        
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.mapView.locationOverlay.icon = NMFOverlayImage(image: image)
                self?.mapView.locationOverlay.iconWidth = CGFloat(advertisement.imageWidth)
                self?.mapView.locationOverlay.iconHeight = CGFloat(advertisement.imageHeight)
            }
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = HomeCardFlowLayout()
        layout.itemSize = HomeStoreCardCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        return layout
    }
}
