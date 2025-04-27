import UIKit

import Common
import DesignSystem
import Model

import NMapsMap
import SnapKit
import Then

final class HomeView: BaseView {
    private let homeFilterSelectable: HomeFilterSelectable
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    let addressButton = AddressButton()
    
    lazy var homeFilterCollectionView = HomeFilterCollectionView(homeFilterSelectable: homeFilterSelectable)
    
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
    
    let feedButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.Home.feedButton, for: .normal)
        button.setTitleColor(Colors.mainGreen.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        button.backgroundColor = Colors.systemWhite.color
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.mainGreen.color.cgColor
        button.layer.shadowColor = Colors.mainGreen.color.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    private var homeFilterTooltip: HomeFilterTooltip?
    private var feedButtonTimer: Timer?
    private var buttonStateFlag = true
    
    init(homeFilterSelectable: HomeFilterSelectable) {
        self.homeFilterSelectable = homeFilterSelectable
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
            currentLocationButton,
            listViewButton,
            collectionView,
            feedButton
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
        
        feedButton.snp.makeConstraints {
            $0.right.equalTo(listViewButton)
            $0.bottom.equalTo(listViewButton.snp.top).offset(-12)
            $0.height.equalTo(44)
        }
    }
    
    func setHiddenResearchButton(isHidden: Bool) {
        UIView.transition(
            with: researchButton,
            duration: 0.3,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.researchButton.transform = isHidden ? .identity : .init(translationX: 0, y: 35)
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
    
    func setAdvertisementMarker(_ advertisement: AdvertisementResponse) {
        guard let urlString = advertisement.image?.url,
              let url = URL(string: urlString) else { return }
        
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.mapView.locationOverlay.icon = NMFOverlayImage(image: image)
                self?.mapView.locationOverlay.iconWidth = CGFloat(advertisement.image?.width ?? 0)
                self?.mapView.locationOverlay.iconHeight = CGFloat(advertisement.image?.height ?? 0)
            }
        }
    }
    
    func showFilterTooltiop(isShow: Bool) {
        if isShow, let cell = homeFilterCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? HomeFilterCell {
            let homeFilterTooltip = HomeFilterTooltip()
            addSubview(homeFilterTooltip)
            homeFilterTooltip.snp.makeConstraints {
                $0.centerX.equalTo(cell)
                $0.top.equalTo(cell.snp.bottom).offset(4)
            }
            self.homeFilterTooltip = homeFilterTooltip
        } else {
            homeFilterTooltip?.removeFromSuperview()
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
    
    func startFeedButtonAnimation() {
        feedButtonTimer?.invalidate()
        feedButtonTimer = nil
        feedButtonTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if buttonStateFlag {
                UIView.animate(withDuration: 0.3) {
                    self.feedButton.setTitle(Strings.Home.feedButton, for: .normal)
                    self.feedButton.setTitleColor(Colors.mainGreen.color, for: .normal)
                    self.feedButton.backgroundColor = Colors.systemWhite.color
                    self.feedButton.layer.borderWidth = 1
                    self.feedButton.layer.borderColor = Colors.mainGreen.color.cgColor
                }
                buttonStateFlag = false
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.feedButton.setTitle(Strings.Home.feedButton2, for: .normal)
                    self.feedButton.setTitleColor(Colors.systemWhite.color, for: .normal)
                    self.feedButton.backgroundColor = Colors.mainGreen.color
                    self.feedButton.layer.borderColor = Colors.systemWhite.color.withAlphaComponent(0.5).cgColor
                }
                buttonStateFlag = true
            }
        }
    }
}
